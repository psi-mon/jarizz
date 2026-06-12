import XCTest
@testable import JarizzCore

final class HotkeyDescriptionPropertyTests: XCTestCase {
    private let knownModifiers = [
        "Control", "Option", "Command", "Shift",
        "LeftShift", "RightShift", "LeftCommand", "RightCommand",
        "LeftOption", "RightOption",
    ]

    func test_prop_allKnownModifiersParse() {
        forAll(knownModifiers, "known modifier + key parses without error") { mod in
            (try? HotkeyDescription(string: "\(mod)+A")) != nil
        }
    }

    func test_prop_unknownModifierAlwaysThrows() {
        let unknowns = ["Super", "Hyper", "Meta", "Win", "Fn", "CapsLock", "Alt"]
        forAll(unknowns, "unknown modifier always throws unknownModifier") { mod in
            do {
                _ = try HotkeyDescription(string: "\(mod)+A")
                return false
            } catch HotkeyParseError.unknownModifier {
                return true
            } catch {
                return false
            }
        }
    }

    func test_prop_modifierDescriptionStartsLowercase() {
        forAll(knownModifiers, "modifier description first char is lowercase") { mod in
            guard let hk = try? HotkeyDescription(string: "\(mod)+A") else { return false }
            return hk.modifiers.allSatisfy { $0.description.first?.isLowercase == true }
        }
    }

    func test_prop_allModifiersArePreservedInOrder() {
        let pairs = knownModifiers.dropLast().enumerated().map { (i, m) in
            (m, knownModifiers[knownModifiers.index(knownModifiers.startIndex, offsetBy: i + 1)])
        }
        forAll(Array(pairs), "modifier order is preserved") { (first, second) in
            guard let hk = try? HotkeyDescription(string: "\(first)+\(second)+Z") else { return false }
            return hk.modifiers.count == 2
                && hk.modifiers[0].rawValue == first
                && hk.modifiers[1].rawValue == second
        }
    }
}
