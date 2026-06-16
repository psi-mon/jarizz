import XCTest
@testable import JarizzCore
import JarizzCoreTestHelpers

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
        forAll([0, 1, 2, 5], "MockWebProviderAdapter.navigationCount equals navigate() call count") { n in
            let adapter = MockWebProviderAdapter(url: "https://example.com")
            for _ in 0..<n { adapter.navigate(to: adapter.url) }
            return adapter.navigationCount == n
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
        forAll([true, false], "adapter navigation count unaffected by setNetworkUnavailable") { setError in
            let adapter = MockWebProviderAdapter(url: "https://example.com")
            adapter.navigate(to: adapter.url)
            var ctrl = AppShellController()
            ctrl.configure(adapter: adapter)
            if setError { ctrl.setNetworkUnavailable() }
            return adapter.navigationCount == 1
        }
    }

    func test_prop_navigatesExactlyOnceRegardlessOfToggleCycles() {
        forAll([1, 2, 3, 5], "navigation happens exactly once across any number of show/hide cycles") { cycles in
            var ctrl = AppShellController()
            let adapter = MockWebProviderAdapter(url: "https://example.com")
            ctrl.configure(adapter: adapter)
            for _ in 0..<cycles {
                ctrl.togglePopover() // show
                ctrl.togglePopover() // hide
            }
            return adapter.navigationCount == 1
        }
    }
}
