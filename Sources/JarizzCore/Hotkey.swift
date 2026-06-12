public struct Hotkey: Equatable, Sendable {
    public let key: String
    public let modifiers: Modifiers

    public struct Modifiers: OptionSet, Sendable {
        public let rawValue: UInt
        public init(rawValue: UInt) { self.rawValue = rawValue }

        public static let control = Modifiers(rawValue: 1 << 0)
        public static let option  = Modifiers(rawValue: 1 << 1)
        public static let command = Modifiers(rawValue: 1 << 2)
        public static let shift   = Modifiers(rawValue: 1 << 3)
    }

    public init(key: String, modifiers: Modifiers) {
        self.key = key
        self.modifiers = modifiers
    }

    public static let defaultHotkey = Hotkey(key: "space", modifiers: [.control, .option])
}
