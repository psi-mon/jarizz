import XCTest
@testable import JarizzCore

final class HotkeyDescriptionTests: XCTestCase {

    func test_parse_leftShiftRightCommandBracket() throws {
        let hk = try HotkeyDescription(string: "LeftShift+RightCommand+]")
        XCTAssertEqual(hk.key, "]")
        XCTAssertEqual(hk.modifiers, [.leftShift, .rightCommand])
    }

    func test_parse_singleModifierAndKey() throws {
        let hk = try HotkeyDescription(string: "Control+Space")
        XCTAssertEqual(hk.key, "Space")
        XCTAssertEqual(hk.modifiers, [.control])
    }

    func test_parse_multipleModifiers() throws {
        let hk = try HotkeyDescription(string: "Control+Option+Space")
        XCTAssertEqual(hk.key, "Space")
        XCTAssertEqual(hk.modifiers, [.control, .option])
    }

    func test_parse_emptyStringThrows() {
        XCTAssertThrowsError(try HotkeyDescription(string: ""))
    }

    func test_parse_noKeyThrows() {
        XCTAssertThrowsError(try HotkeyDescription(string: "Control+"))
    }

    func test_parse_unknownModifierThrows() {
        XCTAssertThrowsError(try HotkeyDescription(string: "Super+A")) { error in
            guard case HotkeyParseError.unknownModifier(let name) = error else {
                return XCTFail("expected unknownModifier, got \(error)")
            }
            XCTAssertEqual(name, "Super")
        }
    }

    func test_modifiersDescription_matchesFeatureFormat() throws {
        let hk = try HotkeyDescription(string: "LeftShift+RightCommand+]")
        XCTAssertEqual(hk.modifiersDescription, "leftShift, rightCommand")
    }
}
