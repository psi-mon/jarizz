public struct PopoverState: Sendable {
    public private(set) var isVisible: Bool

    public init(isVisible: Bool = false) {
        self.isVisible = isVisible
    }

    public mutating func toggle() {
        isVisible = !isVisible
    }

    public mutating func show() {
        isVisible = true
    }

    public mutating func hide() {
        isVisible = false
    }
}
