public protocol WebProviderAdapter: AnyObject {
    var url: String { get }
    var navigationCount: Int { get }
    var usesPersistentSessionStorage: Bool { get }
    var handlesNewWindowsInApp: Bool { get }
    func navigate(to url: String)
}
