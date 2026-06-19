import AppKit
import WebKit
import JarizzCore

final class GeminiWebView: NSObject, WebProviderAdapter {
    let webView: WKWebView
    let url: String
    private(set) var navigationCount: Int = 0
    let usesPersistentSessionStorage: Bool = true
    let handlesNewWindowsInApp: Bool = true
    let focusesInputFieldOnShow: Bool = true

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
}

// MARK: - WKUIDelegate (in-app popups for secondary windows)

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

// MARK: - WKNavigationDelegate (focus injection)

extension GeminiWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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
}
