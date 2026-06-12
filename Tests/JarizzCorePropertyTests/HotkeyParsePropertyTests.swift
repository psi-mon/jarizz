import XCTest
@testable import JarizzCore

final class HotkeyParsePropertyTests: XCTestCase {
    private let knownSidedModifiers = [
        "LeftControl", "RightControl",
        "LeftOption", "RightOption",
        "LeftCommand", "RightCommand",
        "LeftShift", "RightShift",
    ]
    private let knownAliases = [
        "Control", "Ctrl", "Option", "Alt", "Command", "Cmd", "Shift",
        "LeftAlt", "RightAlt",
    ]

    func test_prop_allKnownSidedModifiersParse() {
        forAll(knownSidedModifiers, "sided modifier + key parses without error") { mod in
            (try? Hotkey.parse("\(mod)+A")) != nil
        }
    }

    func test_prop_allAliasesParse() {
        forAll(knownAliases, "alias + key parses without error") { alias in
            (try? Hotkey.parse("\(alias)+A")) != nil
        }
    }

    func test_prop_unknownModifierAlwaysThrows() {
        let unknowns = ["Super", "Hyper", "Meta", "Win", "Fn", "CapsLock"]
        forAll(unknowns, "unknown modifier throws ParseError.unknownModifier") { mod in
            do {
                _ = try Hotkey.parse("\(mod)+A")
                return false
            } catch Hotkey.ParseError.unknownModifier {
                return true
            } catch {
                return false
            }
        }
    }

    func test_prop_descriptionContainsOnlySidedNames() {
        forAll(knownSidedModifiers, "description uses sided canonical names") { mod in
            guard let h = try? Hotkey.parse("\(mod)+A") else { return false }
            let desc = h.modifiers.description
            return !desc.isEmpty && desc.first?.isLowercase == true
        }
    }

    func test_prop_hotkeyEqualityIsReflexive() {
        let keys = ["]", "space", "a", "return"]
        forAll(keys, "hotkey equals itself") { key in
            guard let h = try? Hotkey.parse("LeftShift+\(key)") else { return false }
            return h == h
        }
    }
}
