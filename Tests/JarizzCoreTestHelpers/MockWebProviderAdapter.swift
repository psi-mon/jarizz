import JarizzCore

public final class MockWebProviderAdapter: WebProviderAdapter {
    public let url: String
    public private(set) var navigationCount: Int = 0
    public private(set) var lastNavigatedURL: String?
    public let usesPersistentSessionStorage: Bool = true
    public let handlesNewWindowsInApp: Bool = true
    public let authSessionIsNonEphemeral: Bool = true
    public let focusesInputFieldOnShow: Bool = true
    public private(set) var authSessionTriggerCount: Int = 0
    public private(set) var hasBridgedAuthResult: Bool = false

    public init(url: String) { self.url = url }

    public func navigate(to url: String) {
        lastNavigatedURL = url
        navigationCount += 1
    }

    public func startAuthSession(for url: String, callbackScheme: String) {
        authSessionTriggerCount += 1
    }

    public func handleAuthCallback(url: String) {
        hasBridgedAuthResult = true
    }
}
