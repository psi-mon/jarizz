import XCTest
@testable import JarizzCore

final class PopoverStatePropertyTests: XCTestCase {

    func test_prop_doubleToggleIsIdentity() {
        for initial in [false, true] {
            forAll([initial], "double-toggle returns original visibility") { startVisible in
                var s = PopoverState(isVisible: startVisible)
                s.toggle()
                s.toggle()
                return s.isVisible == startVisible
            }
        }
    }

    func test_prop_showAlwaysMakesVisible() {
        forAll([false, true], "show always results in visible") { startVisible in
            var s = PopoverState(isVisible: startVisible)
            s.show()
            return s.isVisible
        }
    }

    func test_prop_hideAlwaysMakesHidden() {
        forAll([false, true], "hide always results in hidden") { startVisible in
            var s = PopoverState(isVisible: startVisible)
            s.hide()
            return !s.isVisible
        }
    }

    func test_prop_toggleFlipsIsVisible() {
        forAll([false, true], "toggle produces opposite isVisible") { startVisible in
            var s = PopoverState(isVisible: startVisible)
            s.toggle()
            return s.isVisible == !startVisible
        }
    }
}
