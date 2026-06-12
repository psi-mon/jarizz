public struct Hotkey: Equatable, Sendable {
    public let key: String
    public let modifiers: Modifiers

    public struct Modifiers: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        // Side-specific flags
        public static let leftControl  = Modifiers(rawValue: 1 << 0)
        public static let rightControl = Modifiers(rawValue: 1 << 1)
        public static let leftOption   = Modifiers(rawValue: 1 << 2)
        public static let rightOption  = Modifiers(rawValue: 1 << 3)
        public static let leftCommand  = Modifiers(rawValue: 1 << 4)
        public static let rightCommand = Modifiers(rawValue: 1 << 5)
        public static let leftShift    = Modifiers(rawValue: 1 << 6)
        public static let rightShift   = Modifiers(rawValue: 1 << 7)

        // Side-agnostic aliases (either side)
        public static let control: Modifiers = [.leftControl,  .rightControl]
        public static let option:  Modifiers = [.leftOption,   .rightOption]
        public static let command: Modifiers = [.leftCommand,  .rightCommand]
        public static let shift:   Modifiers = [.leftShift,    .rightShift]

        // Alphabetically ordered for stable string representation
        static let namedFlags: [(Modifiers, String)] = [
            (.leftCommand,  "leftCommand"),
            (.leftControl,  "leftControl"),
            (.leftOption,   "leftOption"),
            (.leftShift,    "leftShift"),
            (.rightCommand, "rightCommand"),
            (.rightControl, "rightControl"),
            (.rightOption,  "rightOption"),
            (.rightShift,   "rightShift"),
        ]

        public var description: String {
            Modifiers.namedFlags
                .filter { self.contains($0.0) }
                .map { $0.1 }
                .joined(separator: ", ")
        }
    }

    public init(key: String, modifiers: Modifiers) {
        self.key = key
        self.modifiers = modifiers
    }

    // LeftShift+RightCommand+] per the accepted shell-001 specification
    public static let defaultHotkey = Hotkey(key: "]", modifiers: [.leftShift, .rightCommand])

    public enum ParseError: Error, Equatable {
        case emptyString
        case unknownModifier(String)
        case missingKey
    }

    public static func parse(_ string: String) throws -> Hotkey {
        guard !string.isEmpty else { throw ParseError.emptyString }
        var parts = string.split(separator: "+", omittingEmptySubsequences: false).map(String.init)
        let key = parts.removeLast()
        guard !key.isEmpty else { throw ParseError.missingKey }
        var mods = Modifiers()
        for name in parts {
            switch name {
            case "LeftControl":              mods.insert(.leftControl)
            case "RightControl":             mods.insert(.rightControl)
            case "Control", "Ctrl":          mods.formUnion(.control)
            case "LeftOption", "LeftAlt":    mods.insert(.leftOption)
            case "RightOption", "RightAlt":  mods.insert(.rightOption)
            case "Option", "Alt":            mods.formUnion(.option)
            case "LeftCommand":              mods.insert(.leftCommand)
            case "RightCommand":             mods.insert(.rightCommand)
            case "Command", "Cmd":           mods.formUnion(.command)
            case "LeftShift":                mods.insert(.leftShift)
            case "RightShift":               mods.insert(.rightShift)
            case "Shift":                    mods.formUnion(.shift)
            default:                         throw ParseError.unknownModifier(name)
            }
        }
        return Hotkey(key: key, modifiers: mods)
    }
}
