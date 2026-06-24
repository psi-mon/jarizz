import XCTest
@testable import JarizzCore
import JarizzCoreTestHelpers

final class SettingsControllerPropertyTests: XCTestCase {

    func test_prop_panelSizePercentAlwaysClamped() {
        forAll([-100, 0, 5, 19, 20, 50, 90, 91, 100, 200],
               "panelSizePercent is always in [20, 90]") { input in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            ctrl.setPanelSizePercent(input)
            return ctrl.settings.panelSizePercent >= 20 && ctrl.settings.panelSizePercent <= 90
        }
    }

    func test_prop_atMostOneProviderStarred() throws {
        let urls = ["https://a.example", "https://b.example", "https://c.example"]
        for starName in ["A", "B", "C"] {
            var ctrl = SettingsController(store: InMemorySettingsStore())
            try ctrl.addProvider(name: "A", url: urls[0])
            try ctrl.addProvider(name: "B", url: urls[1])
            try ctrl.addProvider(name: "C", url: urls[2])
            if let id = ctrl.settings.providers.first(where: { $0.name == starName })?.id {
                ctrl.starProvider(id: id)
            }
            let starCount = ctrl.settings.providers.filter { $0.starred }.count
            XCTAssertEqual(starCount, 1, "Expected exactly 1 starred provider after starring \(starName)")
        }
    }

    func test_prop_cycleProviderWrapsAround() throws {
        forAll([2, 3, 5], "cycling N times through N providers returns to index 0") { count in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            for i in 0..<count {
                try? ctrl.addProvider(name: "P\(i)", url: "https://p\(i).example.com")
            }
            for _ in 0..<count { ctrl.cycleProvider() }
            return ctrl.currentProviderIndex == 0
        }
    }

    func test_prop_cycleProviderNoOpForSingleProvider() throws {
        forAll([1, 2, 5], "cycleProvider never changes index when only 1 provider configured") { cycleCount in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            try? ctrl.addProvider(name: "Only", url: "https://only.example.com")
            for _ in 0..<cycleCount { ctrl.cycleProvider() }
            return ctrl.currentProviderIndex == 0
        }
    }

    // MARK: - Rail

    func test_prop_railButtonCountEqualsProviderCount() {
        forAll([0, 1, 3, 6], "railButtonCount always equals settings.providers.count") { count in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            for i in 0..<count {
                try? ctrl.addProvider(name: "P\(i)", url: "https://p\(i).example.com")
            }
            return ctrl.railButtonCount == ctrl.settings.providers.count
        }
    }

    func test_prop_atMostOneButtonActive() throws {
        forAll([1, 2, 4, 6], "at most one provider button is active at any time") { count in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            for i in 0..<count {
                try? ctrl.addProvider(name: "P\(i)", url: "https://p\(i).example.com")
            }
            let activeCount = ctrl.settings.providers.filter { ctrl.providerButtonIsActive(named: $0.name) }.count
            return activeCount <= 1
        }
    }

    func test_prop_collapseRailIsIdempotent() {
        forAll([1, 3], "collapseRail is idempotent — second call has no extra effect") { _ in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            ctrl.collapseRail()
            ctrl.collapseRail()
            return ctrl.railIsCollapsed
        }
    }

    func test_prop_expandRailIsIdempotent() {
        forAll([1, 3], "expandRail is idempotent — second call has no extra effect") { _ in
            var ctrl = SettingsController(store: InMemorySettingsStore())
            ctrl.collapseRail()
            ctrl.expandRail()
            ctrl.expandRail()
            return !ctrl.railIsCollapsed
        }
    }
}
