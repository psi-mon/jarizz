import XCTest
import JarizzCore
import JarizzCoreTestHelpers

public struct AcceptanceWorld {
    public var controller = AppShellController()
    public var lastParsedHotkey: Hotkey?
    public var screenOriginX: Double = 0
    public var screenOriginY: Double = 0
    public var screenWidth: Double = 0
    public var screenHeight: Double = 0
    public var webAdapter: MockWebProviderAdapter?
    public var providerWebAdapters: [String: MockWebProviderAdapter] = [:]
    public var settingsStore: InMemorySettingsStore
    public var settingsCtrl: SettingsController
    public var lastProviderError: ProviderError?
    public var displayedProviderName: String?

    public init() {
        let store = InMemorySettingsStore()
        settingsStore = store
        settingsCtrl = SettingsController(store: store)
    }
}
