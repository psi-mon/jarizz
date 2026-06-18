import XCTest
@testable import JarizzCore
import JarizzCoreTestHelpers

final class AppShellControllerTests: XCTestCase {

    func test_launch_setsRunning() {
        var ctrl = AppShellController()
        XCTAssertFalse(ctrl.isRunning)
        ctrl.launch()
        XCTAssertTrue(ctrl.isRunning)
    }

    func test_togglePopover_whenHidden_becomesVisible() {
        var ctrl = AppShellController()
        ctrl.togglePopover()
        XCTAssertTrue(ctrl.popoverState.isVisible)
    }

    func test_togglePopover_whenVisible_becomesHidden() {
        var ctrl = AppShellController()
        ctrl.togglePopover()
        ctrl.togglePopover()
        XCTAssertFalse(ctrl.popoverState.isVisible)
    }

    func test_dismissPopover_whenVisible_becomesHidden() {
        var ctrl = AppShellController()
        ctrl.togglePopover()
        ctrl.dismissPopover()
        XCTAssertFalse(ctrl.popoverState.isVisible)
    }

    func test_placeholderText() {
        XCTAssertEqual(AppShellController().placeholderText, "jarizz")
    }

    func test_dockIconHidden() {
        XCTAssertTrue(AppShellController().dockIconHidden)
    }

    func test_hotkeyIsDefault() {
        XCTAssertEqual(AppShellController().hotkey, Hotkey.defaultHotkey)
    }

    func test_networkErrorMessage_nilByDefault() {
        XCTAssertNil(AppShellController().networkErrorMessage)
    }

    func test_setNetworkUnavailable_setsErrorMessage() {
        var ctrl = AppShellController()
        ctrl.setNetworkUnavailable()
        XCTAssertEqual(ctrl.networkErrorMessage,
                       "No network connection — check your internet and try again")
    }

    func test_configure_setsAdapter() {
        var ctrl = AppShellController()
        let adapter = MockWebProviderAdapter(url: "https://example.com")
        ctrl.configure(adapter: adapter)
        XCTAssertNotNil(ctrl.webAdapter)
    }

    func test_togglePopover_whenHidden_navigatesToAdapterURL() {
        var ctrl = AppShellController()
        let adapter = MockWebProviderAdapter(url: "https://gemini.google.com/app")
        ctrl.configure(adapter: adapter)
        ctrl.togglePopover()
        XCTAssertEqual(adapter.lastNavigatedURL, "https://gemini.google.com/app")
    }

    func test_togglePopover_navigatesOnlyOnFirstShow() {
        var ctrl = AppShellController()
        let adapter = MockWebProviderAdapter(url: "https://gemini.google.com/app")
        ctrl.configure(adapter: adapter)
        ctrl.togglePopover() // show → navigate
        ctrl.togglePopover() // hide
        ctrl.togglePopover() // show again → no navigate
        XCTAssertEqual(adapter.navigationCount, 1)
    }

    func test_togglePopover_doesNotNavigateWhenNetworkUnavailable() {
        var ctrl = AppShellController()
        let adapter = MockWebProviderAdapter(url: "https://gemini.google.com/app")
        ctrl.configure(adapter: adapter)
        ctrl.setNetworkUnavailable()
        ctrl.togglePopover()
        XCTAssertEqual(adapter.navigationCount, 0)
    }

    func test_mockAdapter_usesPersistentSessionStorage() {
        XCTAssertTrue(MockWebProviderAdapter(url: "https://example.com").usesPersistentSessionStorage)
    }

    func test_mockAdapter_handlesNewWindowsInApp() {
        XCTAssertTrue(MockWebProviderAdapter(url: "https://example.com").handlesNewWindowsInApp)
    }

    func test_mockAdapter_authSessionIsNonEphemeral() {
        XCTAssertTrue(MockWebProviderAdapter(url: "https://example.com").authSessionIsNonEphemeral)
    }

    func test_mockAdapter_focusesInputFieldOnShow() {
        XCTAssertTrue(MockWebProviderAdapter(url: "https://example.com").focusesInputFieldOnShow)
    }

    func test_mockAdapter_authSessionTriggerCount_startsAtZero() {
        XCTAssertEqual(MockWebProviderAdapter(url: "https://example.com").authSessionTriggerCount, 0)
    }

    func test_mockAdapter_startAuthSession_incrementsTriggerCount() {
        let adapter = MockWebProviderAdapter(url: "https://example.com")
        adapter.startAuthSession(for: "https://accounts.google.com", callbackScheme: "com.jarizz.auth")
        XCTAssertEqual(adapter.authSessionTriggerCount, 1)
    }

    func test_mockAdapter_hasBridgedAuthResult_falseByDefault() {
        XCTAssertFalse(MockWebProviderAdapter(url: "https://example.com").hasBridgedAuthResult)
    }

    func test_mockAdapter_handleAuthCallback_setsBridgedFlag() {
        let adapter = MockWebProviderAdapter(url: "https://example.com")
        adapter.handleAuthCallback(url: "com.jarizz.auth://callback")
        XCTAssertTrue(adapter.hasBridgedAuthResult)
    }

    func test_openSettings_dismissesPanel() {
        var ctrl = AppShellController()
        ctrl.togglePopover()
        XCTAssertTrue(ctrl.popoverState.isVisible)
        ctrl.openSettings()
        XCTAssertFalse(ctrl.popoverState.isVisible)
    }

    func test_openSettings_whenPanelHidden_remainsHidden() {
        var ctrl = AppShellController()
        ctrl.openSettings()
        XCTAssertFalse(ctrl.popoverState.isVisible)
    }
}
