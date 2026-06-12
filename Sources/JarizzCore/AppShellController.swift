public struct AppShellController {
    public private(set) var isRunning: Bool = false
    public private(set) var popoverState: PopoverToggleState = .hidden
    public let placeholderText: String = "jarizz"
    public let dockIconHidden: Bool = true

    public init() {}

    public mutating func launch() { isRunning = true }

    public mutating func togglePopover() { popoverState.toggle() }

    public mutating func dismissPopover() { popoverState = .hidden }
}
