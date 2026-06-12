import XCTest
@testable import JarizzCore

final class AppShellControllerPropertyTests: XCTestCase {
    private let allStates: [PopoverToggleState] = [.hidden, .visible]

    func test_prop_dismissAlwaysHides() {
        forAll(allStates, "dismissPopover always results in hidden") { initialState in
            var ctrl = AppShellController()
            if initialState == .visible { ctrl.togglePopover() }
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
        forAll(allStates, "togglePopover does not affect isRunning") { initialPopover in
            var ctrl = AppShellController()
            ctrl.launch()
            if initialPopover == .visible { ctrl.togglePopover() }
            ctrl.togglePopover()
            return ctrl.isRunning
        }
    }
}
