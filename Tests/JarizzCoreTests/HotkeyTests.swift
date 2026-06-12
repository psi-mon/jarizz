import XCTest
@testable import JarizzCore

final class HotkeyTests: XCTestCase {

    // MARK: defaultHotkey

    func testDefaultHotkeyIsLeftShiftRightCommandBracket() {
        let h = Hotkey.defaultHotkey
        XCTAssertEqual(h.key, "]")
        XCTAssertTrue(h.modifiers.contains(.leftShift))
        XCTAssertTrue(h.modifiers.contains(.rightCommand))
        XCTAssertFalse(h.modifiers.contains(.leftCommand))
        XCTAssertFalse(h.modifiers.contains(.control))
        XCTAssertFalse(h.modifiers.contains(.option))
    }

    // MARK: Equality

    func testHotkeyEquality() {
        let a = Hotkey(key: "space", modifiers: [.control, .option])
        let b = Hotkey(key: "space", modifiers: [.control, .option])
        XCTAssertEqual(a, b)
    }

    func testHotkeyInequality() {
        let a = Hotkey(key: "space", modifiers: [.control, .option])
        let b = Hotkey(key: "space", modifiers: [.command])
        XCTAssertNotEqual(a, b)
    }

    // MARK: Side-agnostic aliases

    func testSideAgnosticAliasContainsBothSides() {
        XCTAssertTrue(Hotkey.Modifiers.control.contains(.leftControl))
        XCTAssertTrue(Hotkey.Modifiers.control.contains(.rightControl))
        XCTAssertTrue(Hotkey.Modifiers.shift.contains(.leftShift))
        XCTAssertTrue(Hotkey.Modifiers.shift.contains(.rightShift))
    }

    func testModifiersOptionSet() {
        let mods: Hotkey.Modifiers = [.control, .shift]
        XCTAssertTrue(mods.contains(.control))
        XCTAssertTrue(mods.contains(.shift))
        XCTAssertFalse(mods.contains(.option))
        XCTAssertFalse(mods.contains(.command))
    }

    // MARK: parse

    func testParseSidedModifiers() throws {
        let h = try Hotkey.parse("LeftShift+RightCommand+]")
        XCTAssertEqual(h.key, "]")
        XCTAssertTrue(h.modifiers.contains(.leftShift))
        XCTAssertTrue(h.modifiers.contains(.rightCommand))
        XCTAssertFalse(h.modifiers.contains(.rightShift))
        XCTAssertFalse(h.modifiers.contains(.leftCommand))
    }

    func testParseSideAgnosticModifiers() throws {
        let h = try Hotkey.parse("Control+Option+space")
        XCTAssertEqual(h.key, "space")
        XCTAssertTrue(h.modifiers.contains(.control))
        XCTAssertTrue(h.modifiers.contains(.option))
    }

    func testParseEmptyStringThrows() {
        XCTAssertThrowsError(try Hotkey.parse("")) { error in
            XCTAssertEqual(error as? Hotkey.ParseError, .emptyString)
        }
    }

    func testParseUnknownModifierThrows() {
        XCTAssertThrowsError(try Hotkey.parse("Hyper+a")) { error in
            XCTAssertEqual(error as? Hotkey.ParseError, .unknownModifier("Hyper"))
        }
    }

    // MARK: Modifiers.description

    func testModifiersDescription() throws {
        let h = try Hotkey.parse("LeftShift+RightCommand+]")
        XCTAssertEqual(h.modifiers.description, "leftShift, rightCommand")
    }

    func testModifiersDescriptionIsAlphabetical() {
        let mods: Hotkey.Modifiers = [.rightShift, .leftCommand]
        XCTAssertEqual(mods.description, "leftCommand, rightShift")
    }

    func testEmptyModifiersDescription() {
        XCTAssertEqual(Hotkey.Modifiers().description, "")
    }

    func testParseAllModifierAliases() throws {
        let cases: [(String, Hotkey.Modifiers)] = [
            ("LeftControl+a",  .leftControl),
            ("RightControl+a", .rightControl),
            ("Ctrl+a",         .control),
            ("LeftOption+a",   .leftOption),
            ("LeftAlt+a",      .leftOption),
            ("RightOption+a",  .rightOption),
            ("RightAlt+a",     .rightOption),
            ("Alt+a",          .option),
            ("LeftCommand+a",  .leftCommand),
            ("Command+a",      .command),
            ("Cmd+a",          .command),
            ("RightShift+a",   .rightShift),
            ("Shift+a",        .shift),
        ]
        for (string, expected) in cases {
            let h = try Hotkey.parse(string)
            XCTAssertEqual(h.key, "a", "key for \(string)")
            XCTAssertTrue(h.modifiers.contains(expected), "modifiers for \(string)")
        }
    }

    func testParseMissingKeyThrows() {
        XCTAssertThrowsError(try Hotkey.parse("Control+")) { error in
            XCTAssertEqual(error as? Hotkey.ParseError, .missingKey)
        }
    }
}
