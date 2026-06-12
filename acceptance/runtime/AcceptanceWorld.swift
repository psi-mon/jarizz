import XCTest
import JarizzCore

public struct AcceptanceWorld {
    public var controller = AppShellController()
    public var lastParsedHotkey: HotkeyDescription?
    public var lastError: Error?

    public init() {}
}
