import XCTest
@testable import JarizzCore

final class PopoverStateTests: XCTestCase {
    func testInitiallyHidden() {
        let state = PopoverState()
        XCTAssertFalse(state.isVisible)
    }

    func testToggleShowsFromHidden() {
        var state = PopoverState()
        state.toggle()
        XCTAssertTrue(state.isVisible)
    }

    func testToggleHidesFromVisible() {
        var state = PopoverState(isVisible: true)
        state.toggle()
        XCTAssertFalse(state.isVisible)
    }

    func testShowSetsVisible() {
        var state = PopoverState()
        state.show()
        XCTAssertTrue(state.isVisible)
    }

    func testHideClearsVisible() {
        var state = PopoverState(isVisible: true)
        state.hide()
        XCTAssertFalse(state.isVisible)
    }

    func testDoubleToggleRestoresState() {
        var state = PopoverState()
        state.toggle()
        state.toggle()
        XCTAssertFalse(state.isVisible)
    }
}
