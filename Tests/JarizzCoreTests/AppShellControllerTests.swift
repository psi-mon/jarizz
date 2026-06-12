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
}
