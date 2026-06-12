public struct HotkeyDescription: Equatable {
    public let key: String
    public let modifiers: [HotkeyModifier]

    public init(string: String) throws {
        guard !string.isEmpty else {
            throw HotkeyParseError.emptyString
        }
        let parts = string.split(separator: "+", omittingEmptySubsequences: false).map(String.init)
        guard let keyPart = parts.last, !keyPart.isEmpty else {
            throw HotkeyParseError.noKey
        }
        var mods: [HotkeyModifier] = []
        for part in parts.dropLast() {
            guard let mod = HotkeyModifier(rawValue: part) else {
                throw HotkeyParseError.unknownModifier(part)
            }
            mods.append(mod)
        }
        self.key = keyPart
        self.modifiers = mods
    }

    public var modifiersDescription: String {
        modifiers.map { $0.description }.joined(separator: ", ")
    }
}

public enum HotkeyModifier: String, Equatable {
    case control     = "Control"
    case option      = "Option"
    case command     = "Command"
    case shift       = "Shift"
    case leftShift   = "LeftShift"
    case rightShift  = "RightShift"
    case leftCommand = "LeftCommand"
    case rightCommand = "RightCommand"
    case leftOption  = "LeftOption"
    case rightOption = "RightOption"

    public var description: String { rawValue.prefix(1).lowercased() + rawValue.dropFirst() }
}

public enum HotkeyParseError: Error {
    case emptyString
    case noKey
    case unknownModifier(String)
}
