import JarizzCore

public final class MockWebProviderAdapter: WebProviderAdapter {
    public let url: String
    public private(set) var navigationCount: Int = 0
    public private(set) var lastNavigatedURL: String?
    public let usesPersistentSessionStorage: Bool = true
    public let handlesNewWindowsInApp: Bool = true

    public init(url: String) { self.url = url }

    public func navigate(to url: String) {
        lastNavigatedURL = url
        navigationCount += 1
    }
}
