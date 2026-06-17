public struct AppSettings: Codable, Equatable {
    public var hotkey: String
    public var panelSizePercent: Int
    public var providers: [Provider]

    public init(hotkey: String = "LeftShift+RightCommand+]",
                panelSizePercent: Int = 50,
                providers: [Provider] = []) {
        self.hotkey = hotkey
        self.panelSizePercent = panelSizePercent
        self.providers = providers
    }
}
