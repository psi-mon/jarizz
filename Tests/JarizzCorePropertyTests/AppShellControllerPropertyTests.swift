import XCTest
@testable import JarizzCore

final class AppShellControllerPropertyTests: XCTestCase {

    func test_prop_dismissAlwaysHides() {
        forAll([false, true], "dismissPopover always results in hidden") { startVisible in
            var ctrl = AppShellController()
            if startVisible { ctrl.togglePopover() }
            ctrl.dismissPopover()
            return !ctrl.popoverState.isVisible
        }
    }

    func test_prop_launchIsIdempotent() {
        var ctrl = AppShellController()
        ctrl.launch()
        ctrl.launch()
        XCTAssertTrue(ctrl.isRunning)
    }

    func test_prop_togglePreservesRunningState() {
        forAll([false, true], "togglePopover does not affect isRunning") { startVisible in
            var ctrl = AppShellController()
            ctrl.launch()
            if startVisible { ctrl.togglePopover() }
            ctrl.togglePopover()
            return ctrl.isRunning
        }
    }
}
