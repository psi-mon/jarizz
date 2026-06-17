import CoreGraphics

public struct AppShellController {
    public private(set) var isRunning: Bool = false
    public private(set) var popoverState: PopoverState = PopoverState()
    public let hotkey: Hotkey = .defaultHotkey
    public let placeholderText: String = "jarizz"
    public let dockIconHidden: Bool = true
    public let panelAnimatesOnShow: Bool = true
    public private(set) var networkErrorMessage: String? = nil
    public private(set) var webAdapter: (any WebProviderAdapter)?

    public init() {}

    public mutating func configure(adapter: any WebProviderAdapter) {
        webAdapter = adapter
    }

    public mutating func setNetworkUnavailable() {
        networkErrorMessage = "No network connection — check your internet and try again"
    }

    public mutating func launch() { isRunning = true }

    public mutating func togglePopover() {
        popoverState.toggle()
        if popoverState.isVisible, let adapter = webAdapter,
           adapter.navigationCount == 0, networkErrorMessage == nil {
            adapter.navigate(to: adapter.url)
        }
    }

    public mutating func dismissPopover() { popoverState.hide() }

    public mutating func openSettings() { popoverState.hide() }

    public func panelFrame(for screenFrame: CGRect) -> CGRect {
        PanelGeometry.frame(for: screenFrame)
    }
}
