import XCTest
@testable import JarizzCore

final class HotkeyPropertyTests: XCTestCase {
    private let allModifiers: [Hotkey.Modifiers] = [.control, .option, .command, .shift]

    func test_prop_singleModifierContainsOnlyItself() {
        forAll(allModifiers, "single modifier set contains only that modifier") { mod in
            let others = [Hotkey.Modifiers.control, .option, .command, .shift].filter { $0 != mod }
            return others.allSatisfy { !mod.contains($0) }
        }
    }

    func test_prop_combinedModifiersContainBothComponents() {
        let pairs: [(Hotkey.Modifiers, Hotkey.Modifiers)] = [
            (.control, .option), (.control, .command), (.option, .shift), (.command, .shift),
        ]
        forAll(pairs, "combined set contains both components") { (a, b) in
            let combined: Hotkey.Modifiers = [a, b]
            return combined.contains(a) && combined.contains(b)
        }
    }

    func test_prop_modifierCombinationIsCommutative() {
        let pairs: [(Hotkey.Modifiers, Hotkey.Modifiers)] = [
            (.control, .option), (.command, .shift), (.control, .shift),
        ]
        forAll(pairs, "modifier union is commutative") { (a, b) in
            Hotkey.Modifiers([a, b]) == Hotkey.Modifiers([b, a])
        }
    }

    func test_prop_hotkeyEqualityIsReflexive() {
        let keys = ["space", "a", "return", "]"]
        forAll(keys, "hotkey equals itself") { key in
            let h = Hotkey(key: key, modifiers: [.control, .option])
            return h == h
        }
    }
}
