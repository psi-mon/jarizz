import Foundation
import JarizzCore

final class SettingsViewModel: ObservableObject {
    @Published var controller: SettingsController

    init(store: any SettingsStore) {
        controller = SettingsController(store: store)
    }
}
