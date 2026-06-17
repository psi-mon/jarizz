import JarizzCore

public final class InMemorySettingsStore: SettingsStore {
    private var stored: AppSettings

    public init(initial: AppSettings = AppSettings()) {
        stored = initial
    }

    public func load() -> AppSettings { stored }
    public func save(_ settings: AppSettings) { stored = settings }
}
