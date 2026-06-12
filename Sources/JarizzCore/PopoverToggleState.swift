public enum PopoverToggleState: String, Equatable {
    case hidden
    case visible

    public mutating func toggle() {
        self = self == .hidden ? .visible : .hidden
    }

    public var isVisible: Bool { self == .visible }
}
