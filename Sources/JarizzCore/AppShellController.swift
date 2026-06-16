import CoreGraphics

public struct AppShellController {
    public private(set) var isRunning: Bool = false
    public private(set) var popoverState: PopoverState = PopoverState()
    public let hotkey: Hotkey = .defaultHotkey
    public let placeholderText: String = "jarizz"
    public let dockIconHidden: Bool = true
    public let panelAnimatesOnShow: Bool = true
    public let webProviderURL: String = "https://gemini.google.com/app"
    public private(set) var webNavigationCount: Int = 0
    public private(set) var networkErrorMessage: String? = nil

    public init() {}

    public mutating func notifyWebViewDidLoad() {
        webNavigationCount += 1
    }

    public mutating func setNetworkUnavailable() {
        networkErrorMessage = "No network connection — check your internet and try again"
    }

    public mutating func launch() { isRunning = true }

    public mutating func togglePopover() { popoverState.toggle() }

    public mutating func dismissPopover() { popoverState.hide() }

    public func panelFrame(for screenFrame: CGRect) -> CGRect {
        PanelGeometry.frame(for: screenFrame)
    }
}
