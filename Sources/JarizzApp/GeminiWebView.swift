import AppKit
import AuthenticationServices
import WebKit
import JarizzCore

final class GeminiWebView: NSObject, WebProviderAdapter {
    let webView: WKWebView
    let url: String
    weak var presentationAnchor: NSWindow?

    private(set) var navigationCount: Int = 0
    let usesPersistentSessionStorage: Bool = true
    let handlesNewWindowsInApp: Bool = true
    let authSessionIsNonEphemeral: Bool = true
    let focusesInputFieldOnShow: Bool = true
    private(set) var authSessionTriggerCount: Int = 0
    private(set) var hasBridgedAuthResult: Bool = false
    private var authSession: ASWebAuthenticationSession?

    init(url: String) {
        self.url = url
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.default()
        webView = WKWebView(frame: .zero, configuration: config)
        super.init()
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    func navigate(to url: String) {
        guard let target = URL(string: url) else { return }
        webView.load(URLRequest(url: target))
        navigationCount += 1
    }

    func startAuthSession(for url: String, callbackScheme: String) {
        guard let authURL = URL(string: url) else { return }
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { [weak self] callbackURL, error in
            guard let callbackURL, error == nil else { return }
            DispatchQueue.main.async {
                self?.handleAuthCallback(url: callbackURL.absoluteString)
            }
        }
        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = self
        session.start()
        authSession = session
        authSessionTriggerCount += 1
    }

    func handleAuthCallback(url: String) {
        hasBridgedAuthResult = true
        copyGoogleCookiesToWebView { [weak self] in
            guard let self, let target = URL(string: self.url) else { return }
            self.webView.load(URLRequest(url: target))
        }
    }

    private func copyGoogleCookiesToWebView(then completion: @escaping () -> Void) {
        let domains = ["google.com", "accounts.google.com", "googleapis.com"]
        let cookies = HTTPCookieStorage.shared.cookies?.filter { cookie in
            domains.contains(where: { cookie.domain.hasSuffix($0) })
        } ?? []
        guard !cookies.isEmpty else { completion(); return }
        let store = WKWebsiteDataStore.default().httpCookieStore
        let group = DispatchGroup()
        for cookie in cookies {
            group.enter()
            store.setCookie(cookie) { group.leave() }
        }
        group.notify(queue: .main, execute: completion)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GeminiWebView: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        presentationAnchor ?? NSApp.keyWindow ?? NSApp.windows.first ?? NSWindow()
    }
}

// MARK: - WKUIDelegate (in-app popups for non-auth windows)

extension GeminiWebView: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.uiDelegate = self
        popup.autoresizingMask = [.width, .height]
        webView.addSubview(popup)
        return popup
    }
}

// MARK: - WKNavigationDelegate (focus injection + auth intercept)

extension GeminiWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Focus the primary input field once the page finishes loading.
        let js = """
            (function() {
                var el = document.querySelector('[contenteditable="true"]')
                    || document.querySelector('textarea')
                    || document.querySelector('[role="textbox"]');
                if (el) { el.focus(); }
            })();
            """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let host = url.host else {
            decisionHandler(.allow)
            return
        }
        // Intercept Google OAuth redirects and handle via ASWebAuthenticationSession.
        let isGoogleAuth = (host.contains("accounts.google.com") || host.contains("oauth2.googleapis.com"))
            && (url.path.contains("/o/oauth2") || url.path.contains("/signin"))
        if isGoogleAuth {
            decisionHandler(.cancel)
            startAuthSession(for: url.absoluteString, callbackScheme: "com.jarizz.auth")
        } else {
            decisionHandler(.allow)
        }
    }
}
