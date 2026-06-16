import XCTest
@testable import JarizzCore

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

    func test_webProviderURL_isGemini() {
        XCTAssertEqual(AppShellController().webProviderURL, "https://gemini.google.com/app")
    }

    func test_webNavigationCount_startsAtZero() {
        XCTAssertEqual(AppShellController().webNavigationCount, 0)
    }

    func test_notifyWebViewDidLoad_incrementsCount() {
        var ctrl = AppShellController()
        ctrl.notifyWebViewDidLoad()
        XCTAssertEqual(ctrl.webNavigationCount, 1)
    }

    func test_notifyWebViewDidLoad_canBeCalledMultipleTimes() {
        var ctrl = AppShellController()
        ctrl.notifyWebViewDidLoad()
        ctrl.notifyWebViewDidLoad()
        XCTAssertEqual(ctrl.webNavigationCount, 2)
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
}
