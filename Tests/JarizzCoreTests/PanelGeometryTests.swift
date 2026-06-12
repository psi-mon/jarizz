import XCTest
@testable import JarizzCore

final class PanelGeometryTests: XCTestCase {

    func test_size_isHalfOfScreen() {
        let screen = CGRect(x: 0, y: 0, width: 2560, height: 1440)
        let size = PanelGeometry.size(for: screen)
        XCTAssertEqual(size.width, 1280)
        XCTAssertEqual(size.height, 720)
    }

    func test_size_secondExample() {
        let screen = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let size = PanelGeometry.size(for: screen)
        XCTAssertEqual(size.width, 960)
        XCTAssertEqual(size.height, 540)
    }

    func test_origin_centeredOnScreen() {
        let screen = CGRect(x: 0, y: 0, width: 2560, height: 1440)
        let size = PanelGeometry.size(for: screen)
        let origin = PanelGeometry.origin(for: size, in: screen)
        XCTAssertEqual(origin.x, 640)
        XCTAssertEqual(origin.y, 360)
    }

    func test_frame_centeredAtHalfSize() {
        let screen = CGRect(x: 0, y: 0, width: 2560, height: 1440)
        let frame = PanelGeometry.frame(for: screen)
        XCTAssertEqual(frame.width, 1280)
        XCTAssertEqual(frame.height, 720)
        XCTAssertEqual(frame.midX, screen.midX)
        XCTAssertEqual(frame.midY, screen.midY)
    }

    func test_frame_offsetScreen() {
        let screen = CGRect(x: 2560, y: 0, width: 1920, height: 1080)
        let frame = PanelGeometry.frame(for: screen)
        XCTAssertEqual(frame.width, 960)
        XCTAssertEqual(frame.height, 540)
        XCTAssertEqual(frame.midX, screen.midX)
        XCTAssertEqual(frame.midY, screen.midY)
    }

    func test_controller_panelAnimatesOnShow() {
        XCTAssertTrue(AppShellController().panelAnimatesOnShow)
    }

    func test_controller_panelFrame() {
        let ctrl = AppShellController()
        let screen = CGRect(x: 0, y: 0, width: 2560, height: 1440)
        let frame = ctrl.panelFrame(for: screen)
        XCTAssertEqual(frame.width, 1280)
        XCTAssertEqual(frame.height, 720)
    }
}
