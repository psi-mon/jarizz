import XCTest
@testable import JarizzCore

final class PopoverToggleStatePropertyTests: XCTestCase {
    private let allStates: [PopoverToggleState] = [.hidden, .visible]

    func test_prop_doubleToggleIsIdentity() {
        forAll(allStates, "double-toggle returns original state") { state in
            var s = state
            s.toggle()
            s.toggle()
            return s == state
        }
    }

    func test_prop_isVisibleMatchesVisibleCase() {
        forAll(allStates, "isVisible iff state == .visible") { state in
            state.isVisible == (state == .visible)
        }
    }

    func test_prop_toggleFlipsIsVisible() {
        forAll(allStates, "toggle produces opposite isVisible") { state in
            var s = state
            let before = s.isVisible
            s.toggle()
            return s.isVisible == !before
        }
    }
}
