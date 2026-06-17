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
            ctrl.starProvider(named: starName)
            let starCount = ctrl.settings.providers.filter { $0.starred }.count
            XCTAssertEqual(starCount, 1, "Expected exactly 1 starred provider after starring \(starName)")
        }
    }
}
