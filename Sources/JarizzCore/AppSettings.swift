public struct AppSettings: Codable, Equatable {
    public var hotkey: String
    public var panelSizePercent: Int
    public var providers: [Provider]
    public var railCollapsed: Bool

    public init(hotkey: String = "LeftShift+RightCommand+]",
                panelSizePercent: Int = 50,
                providers: [Provider] = [],
                railCollapsed: Bool = false) {
        self.hotkey = hotkey
        self.panelSizePercent = panelSizePercent
        self.providers = providers
        self.railCollapsed = railCollapsed
    }
}
