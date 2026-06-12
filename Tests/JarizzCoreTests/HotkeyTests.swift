import XCTest
@testable import JarizzCore

final class HotkeyTests: XCTestCase {
    func testDefaultHotkeyIsControlOptionSpace() {
        let h = Hotkey.defaultHotkey
        XCTAssertEqual(h.key, "space")
        XCTAssertTrue(h.modifiers.contains(.control))
        XCTAssertTrue(h.modifiers.contains(.option))
        XCTAssertFalse(h.modifiers.contains(.command))
        XCTAssertFalse(h.modifiers.contains(.shift))
    }

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

    func testModifiersOptionSet() {
        let mods: Hotkey.Modifiers = [.control, .shift]
        XCTAssertTrue(mods.contains(.control))
        XCTAssertTrue(mods.contains(.shift))
        XCTAssertFalse(mods.contains(.option))
        XCTAssertFalse(mods.contains(.command))
    }
}
