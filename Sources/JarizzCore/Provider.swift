import Foundation

public struct Provider: Codable, Equatable {
    public let id: UUID
    public var name: String
    public var url: String
    public var starred: Bool

    public init(id: UUID = UUID(), name: String, url: String, starred: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.starred = starred
    }
}

public enum ProviderError: Error, Equatable {
    case invalidURL
    case duplicateURL
    case nameRequired
    case maxProvidersReached
}
