import XCTest
@testable import JarizzCore

final class PanelGeometryPropertyTests: XCTestCase {
    private let screenSizes: [CGSize] = [
        CGSize(width: 2560, height: 1440),
        CGSize(width: 1920, height: 1080),
        CGSize(width: 1440, height: 900),
        CGSize(width: 1280, height: 800),
    ]

    func test_prop_sizeIsHalfOfScreen() {
        forAll(screenSizes, "panel size is exactly half the screen dimensions") { size in
            let screen = CGRect(origin: .zero, size: size)
            let panelSize = PanelGeometry.size(for: screen)
            return panelSize.width == size.width * 0.5
                && panelSize.height == size.height * 0.5
        }
    }

    func test_prop_frameMidPointMatchesScreenMidPoint() {
        forAll(screenSizes, "panel center equals screen center") { size in
            let screen = CGRect(origin: .zero, size: size)
            let frame = PanelGeometry.frame(for: screen)
            return frame.midX == screen.midX && frame.midY == screen.midY
        }
    }

    func test_prop_frameMidPointPreservedForOffsetScreens() {
        let offsets: [CGPoint] = [
            CGPoint(x: 2560, y: 0), CGPoint(x: 0, y: 1440), CGPoint(x: 1920, y: 200),
        ]
        forAll(offsets, "panel center equals screen center for offset screens") { origin in
            let screen = CGRect(origin: origin, size: CGSize(width: 1920, height: 1080))
            let frame = PanelGeometry.frame(for: screen)
            return frame.midX == screen.midX && frame.midY == screen.midY
        }
    }

    func test_prop_controllerDelegatesGeometryToPanelGeometry() {
        forAll(screenSizes, "AppShellController.panelFrame matches PanelGeometry.frame") { size in
            let screen = CGRect(origin: .zero, size: size)
            let ctrl = AppShellController()
            return ctrl.panelFrame(for: screen) == PanelGeometry.frame(for: screen)
        }
    }
}
