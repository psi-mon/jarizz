public protocol WebProviderAdapter: AnyObject {
    var url: String { get }
    var navigationCount: Int { get }
    var usesPersistentSessionStorage: Bool { get }
    var handlesNewWindowsInApp: Bool { get }
    var authSessionIsNonEphemeral: Bool { get }
    var focusesInputFieldOnShow: Bool { get }
    var authSessionTriggerCount: Int { get }
    var hasBridgedAuthResult: Bool { get }
    func navigate(to url: String)
    func startAuthSession(for url: String, callbackScheme: String)
    func handleAuthCallback(url: String)
}
