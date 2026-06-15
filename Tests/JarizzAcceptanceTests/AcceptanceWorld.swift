import XCTest
import JarizzCore

public struct AcceptanceWorld {
    public var controller = AppShellController()
    public var lastParsedHotkey: Hotkey?
    public var screenOriginX: Double = 0
    public var screenOriginY: Double = 0
    public var screenWidth: Double = 0
    public var screenHeight: Double = 0

    public init() {}
}
