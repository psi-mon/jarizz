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

    func test_prop_navigationCountAccumulates() {
        forAll([0, 1, 2, 5], "webNavigationCount equals notifyWebViewDidLoad call count") { n in
            var ctrl = AppShellController()
            for _ in 0..<n { ctrl.notifyWebViewDidLoad() }
            return ctrl.webNavigationCount == n
        }
    }

    func test_prop_setNetworkUnavailableIsIdempotent() {
        forAll([1, 2, 3], "setNetworkUnavailable produces same message regardless of call count") { callCount in
            var ctrl = AppShellController()
            for _ in 0..<callCount { ctrl.setNetworkUnavailable() }
            return ctrl.networkErrorMessage == "No network connection — check your internet and try again"
        }
    }

    func test_prop_navigationCountUnaffectedByNetworkError() {
        forAll([true, false], "webNavigationCount unaffected by setNetworkUnavailable") { setError in
            var ctrl = AppShellController()
            ctrl.notifyWebViewDidLoad()
            if setError { ctrl.setNetworkUnavailable() }
            return ctrl.webNavigationCount == 1
        }
    }
}
