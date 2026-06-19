import Foundation

public struct SettingsController {
    public private(set) var settings: AppSettings
    private let store: any SettingsStore

    public init(store: any SettingsStore) {
        self.store = store
        self.settings = store.load()
    }

    public mutating func setHotkey(_ hotkey: String) {
        settings.hotkey = hotkey
        store.save(settings)
    }

    public mutating func setPanelSizePercent(_ percent: Int) {
        settings.panelSizePercent = max(20, min(90, percent))
        store.save(settings)
    }

    public mutating func addProvider(name: String, url: String) throws {
        try validateProviderInput(name: name, url: url)
        guard !settings.providers.contains(where: { $0.url == url }) else { throw ProviderError.duplicateURL }
        settings.providers.append(Provider(name: name, url: url))
        store.save(settings)
    }

    public mutating func removeProvider(named name: String) {
        settings.providers.removeAll { $0.name == name }
        store.save(settings)
    }

    public mutating func editProvider(id: UUID, name: String, url: String) throws {
        try validateProviderInput(name: name, url: url)
        guard !settings.providers.contains(where: { $0.url == url && $0.id != id }) else {
            throw ProviderError.duplicateURL
        }
        if let idx = settings.providers.firstIndex(where: { $0.id == id }) {
            settings.providers[idx].name = name
            settings.providers[idx].url = url
        }
        store.save(settings)
    }

    public mutating func starProvider(named name: String) {
        for idx in settings.providers.indices {
            settings.providers[idx].starred = settings.providers[idx].name == name
        }
        store.save(settings)
    }

    public var activeProvider: Provider? {
        settings.providers.first(where: { $0.starred }) ?? settings.providers.first
    }

    public private(set) var currentProviderIndex: Int = 0

    public var currentProvider: Provider? {
        settings.providers[safe: currentProviderIndex]
    }

    public mutating func cycleProvider() {
        guard settings.providers.count > 1 else { return }
        currentProviderIndex = (currentProviderIndex + 1) % settings.providers.count
    }

    public var panelContentMessage: String? {
        settings.providers.isEmpty ? "Add a provider in Settings to get started" : nil
    }

    public mutating func reload() {
        settings = store.load()
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private func validateProviderInput(name: String, url: String) throws {
    guard !name.isEmpty else { throw ProviderError.nameRequired }
    guard isValidProviderURL(url) else { throw ProviderError.invalidURL }
}

private func isValidProviderURL(_ string: String) -> Bool {
    guard let url = URL(string: string),
          let scheme = url.scheme,
          ["http", "https"].contains(scheme),
          let host = url.host, !host.isEmpty else { return false }
    return true
}
