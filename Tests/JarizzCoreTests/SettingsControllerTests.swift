import XCTest
@testable import JarizzCore
import JarizzCoreTestHelpers

final class SettingsControllerTests: XCTestCase {

    // MARK: - Defaults

    func test_defaultHotkey() {
        let ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertEqual(ctrl.settings.hotkey, "LeftShift+RightCommand+]")
    }

    func test_defaultPanelSizePercent() {
        let ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertEqual(ctrl.settings.panelSizePercent, 50)
    }

    func test_defaultProvidersEmpty() {
        let ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertTrue(ctrl.settings.providers.isEmpty)
    }

    // MARK: - Hotkey

    func test_setHotkey_appliesImmediately() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        ctrl.setHotkey("LeftShift+RightOption+P")
        XCTAssertEqual(ctrl.settings.hotkey, "LeftShift+RightOption+P")
    }

    func test_setHotkey_persists() {
        let store = InMemorySettingsStore()
        var ctrl = SettingsController(store: store)
        ctrl.setHotkey("LeftShift+RightOption+P")
        ctrl.reload()
        XCTAssertEqual(ctrl.settings.hotkey, "LeftShift+RightOption+P")
    }

    // MARK: - Panel size

    func test_setPanelSizePercent_appliesImmediately() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        ctrl.setPanelSizePercent(30)
        XCTAssertEqual(ctrl.settings.panelSizePercent, 30)
    }

    func test_setPanelSizePercent_clampedToMinimum() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        ctrl.setPanelSizePercent(5)
        XCTAssertEqual(ctrl.settings.panelSizePercent, 20)
    }

    func test_setPanelSizePercent_clampedToMaximum() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        ctrl.setPanelSizePercent(95)
        XCTAssertEqual(ctrl.settings.panelSizePercent, 90)
    }

    func test_setPanelSizePercent_persists() {
        let store = InMemorySettingsStore()
        var ctrl = SettingsController(store: store)
        ctrl.setPanelSizePercent(70)
        ctrl.reload()
        XCTAssertEqual(ctrl.settings.panelSizePercent, 70)
    }

    // MARK: - Providers

    func test_addProvider_appearsInList() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        XCTAssertTrue(ctrl.settings.providers.contains { $0.name == "Gemini" })
    }

    func test_addProvider_emptyName_throws() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertThrowsError(try ctrl.addProvider(name: "", url: "https://example.com")) { err in
            XCTAssertEqual(err as? ProviderError, .nameRequired)
        }
    }

    func test_addProvider_invalidURL_throws() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertThrowsError(try ctrl.addProvider(name: "Test", url: "not-a-url")) { err in
            XCTAssertEqual(err as? ProviderError, .invalidURL)
        }
    }

    func test_addProvider_bareHTTP_throws() {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertThrowsError(try ctrl.addProvider(name: "Test", url: "http://")) { err in
            XCTAssertEqual(err as? ProviderError, .invalidURL)
        }
    }

    func test_addProvider_duplicateURL_throws() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        XCTAssertThrowsError(try ctrl.addProvider(name: "Duplicate", url: "https://gemini.google.com/app")) { err in
            XCTAssertEqual(err as? ProviderError, .duplicateURL)
        }
    }

    func test_removeProvider_removesFromList() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        ctrl.removeProvider(named: "Gemini")
        XCTAssertFalse(ctrl.settings.providers.contains { $0.name == "Gemini" })
    }

    func test_editProvider_updatesNameAndURL() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Old Name", url: "https://old.example")
        let id = ctrl.settings.providers[0].id
        try ctrl.editProvider(id: id, name: "New Name", url: "https://new.example")
        XCTAssertTrue(ctrl.settings.providers.contains { $0.name == "New Name" && $0.url == "https://new.example" })
        XCTAssertFalse(ctrl.settings.providers.contains { $0.name == "Old Name" })
    }

    func test_starProvider_setsStarred() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        ctrl.starProvider(named: "Gemini")
        XCTAssertTrue(ctrl.settings.providers.first { $0.name == "Gemini" }?.starred ?? false)
    }

    func test_starProvider_removesStarFromPrevious() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        try ctrl.addProvider(name: "ChatGPT", url: "https://chatgpt.com")
        ctrl.starProvider(named: "Gemini")
        ctrl.starProvider(named: "ChatGPT")
        XCTAssertFalse(ctrl.settings.providers.first { $0.name == "Gemini" }?.starred ?? true)
        XCTAssertTrue(ctrl.settings.providers.first { $0.name == "ChatGPT" }?.starred ?? false)
    }

    func test_activeProvider_returnsStarred() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        try ctrl.addProvider(name: "ChatGPT", url: "https://chatgpt.com")
        ctrl.starProvider(named: "ChatGPT")
        XCTAssertEqual(ctrl.activeProvider?.name, "ChatGPT")
    }

    func test_activeProvider_returnsFirstWhenNoneStarred() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        try ctrl.addProvider(name: "ChatGPT", url: "https://chatgpt.com")
        XCTAssertEqual(ctrl.activeProvider?.name, "Gemini")
    }

    func test_activeProvider_nilWhenEmpty() {
        let ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertNil(ctrl.activeProvider)
    }

    func test_panelContentMessage_whenNoProviders() {
        let ctrl = SettingsController(store: InMemorySettingsStore())
        XCTAssertEqual(ctrl.panelContentMessage, "Add a provider in Settings to get started")
    }

    func test_panelContentMessage_nilWhenProvidersExist() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        XCTAssertNil(ctrl.panelContentMessage)
    }

    func test_providers_persistAfterRestart() throws {
        let store = InMemorySettingsStore()
        var ctrl = SettingsController(store: store)
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        ctrl.reload()
        XCTAssertTrue(ctrl.settings.providers.contains { $0.name == "Gemini" })
    }

    // MARK: - Provider cycling

    func test_currentProviderIndex_startsAtZero() {
        XCTAssertEqual(SettingsController(store: InMemorySettingsStore()).currentProviderIndex, 0)
    }

    func test_cycleProvider_advancesToNext() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        try ctrl.addProvider(name: "ChatGPT", url: "https://chatgpt.com")
        ctrl.cycleProvider()
        XCTAssertEqual(ctrl.currentProvider?.name, "ChatGPT")
    }

    func test_cycleProvider_wrapsFromLast() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        try ctrl.addProvider(name: "ChatGPT", url: "https://chatgpt.com")
        ctrl.cycleProvider()
        ctrl.cycleProvider()
        XCTAssertEqual(ctrl.currentProvider?.name, "Gemini")
    }

    func test_cycleProvider_singleProvider_doesNothing() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        ctrl.cycleProvider()
        XCTAssertEqual(ctrl.currentProvider?.name, "Gemini")
    }

    func test_currentProvider_nilWhenNoProviders() {
        XCTAssertNil(SettingsController(store: InMemorySettingsStore()).currentProvider)
    }

    func test_starredProvider_persistsAfterRestart() throws {
        let store = InMemorySettingsStore()
        var ctrl = SettingsController(store: store)
        try ctrl.addProvider(name: "Gemini", url: "https://gemini.google.com/app")
        ctrl.starProvider(named: "Gemini")
        ctrl.reload()
        XCTAssertTrue(ctrl.settings.providers.first { $0.name == "Gemini" }?.starred ?? false)
    }

    func test_editProvider_duplicateURL_throws() throws {
        var ctrl = SettingsController(store: InMemorySettingsStore())
        try ctrl.addProvider(name: "A", url: "https://a.example")
        try ctrl.addProvider(name: "B", url: "https://b.example")
        let idA = ctrl.settings.providers[0].id
        XCTAssertThrowsError(try ctrl.editProvider(id: idA, name: "A", url: "https://b.example")) { err in
            XCTAssertEqual(err as? ProviderError, .duplicateURL)
        }
    }
}
