import XCTest
@testable import JarizzCore

final class PopoverToggleStateTests: XCTestCase {

    func test_toggle_hiddenBecomesVisible() {
        var state = PopoverToggleState.hidden
        state.toggle()
        XCTAssertEqual(state, .visible)
    }

    func test_toggle_visibleBecomesHidden() {
        var state = PopoverToggleState.visible
        state.toggle()
        XCTAssertEqual(state, .hidden)
    }

    func test_isVisible_whenVisible() {
        XCTAssertTrue(PopoverToggleState.visible.isVisible)
    }

    func test_isVisible_whenHidden() {
        XCTAssertFalse(PopoverToggleState.hidden.isVisible)
    }
}
