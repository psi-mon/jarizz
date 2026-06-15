import XCTest
import JarizzCore

// (keyword, regex-pattern, handler)
// keyword "*" matches any keyword
let stepHandlerTable: [(String, String, (inout AcceptanceWorld, String) -> Void)] = [

    // Setup steps (Given/And)
    ("Given", "the app is not running", { world, _ in
        world.controller = AppShellController()
    }),
    ("Given", "the app is running", { world, _ in
        world.controller = AppShellController()
        world.controller.launch()
    }),
    ("Given", "the (?:popover|panel) is hidden", { world, _ in
        if world.controller.popoverState.isVisible { world.controller.dismissPopover() }
    }),
    ("Given", "the (?:popover|panel) is visible", { world, _ in
        if !world.controller.popoverState.isVisible { world.controller.togglePopover() }
    }),
    ("Given", #"the (?:popover|panel) state is "(.+)""#, { world, text in
        let inner = extractQuoted(text)
        world.controller = AppShellController()
        if inner == "visible" { world.controller.togglePopover() }
    }),
    ("Given", #"the mouse pointer is on a screen with frame origin "(\d+)" "(\d+)" and size "(\d+)" by "(\d+)""#, { world, text in
        let parts = extractAllQuoted(text)
        world.screenOriginX = Double(parts[safe: 0] ?? "0") ?? 0
        world.screenOriginY = Double(parts[safe: 1] ?? "0") ?? 0
        world.screenWidth = Double(parts[safe: 2] ?? "0") ?? 0
        world.screenHeight = Double(parts[safe: 3] ?? "0") ?? 0
    }),
    ("Given", #"the mouse pointer is on a screen with frame size "(\d+)" by "(\d+)""#, { world, text in
        let parts = extractAllQuoted(text)
        world.screenWidth = Double(parts[safe: 0] ?? "0") ?? 0
        world.screenHeight = Double(parts[safe: 1] ?? "0") ?? 0
    }),

    // Action steps (When)
    ("When", "the app launches", { world, _ in
        world.controller.launch()
    }),
    ("When", #"the user presses the global hotkey "(.+)""#, { world, _ in
        world.controller.togglePopover()
    }),
    ("When", "the user clicks the menubar icon", { world, _ in
        world.controller.togglePopover()
    }),
    ("When", #"the user presses "Escape""#, { world, _ in
        world.controller.dismissPopover()
    }),
    ("When", "the user clicks outside the (?:popover|panel)", { world, _ in
        world.controller.dismissPopover()
    }),
    ("When", "the (?:popover|panel) is toggled", { world, _ in
        world.controller.togglePopover()
    }),
    ("When", #"the hotkey string "(.+)" is parsed"#, { world, text in
        let inner = extractQuoted(text)
        do {
            world.lastParsedHotkey = try Hotkey.parse(inner)
        } catch {
            XCTFail("Failed to parse hotkey \(inner): \(error)")
        }
    }),

    // Assertion steps (Then/And)
    ("Then", "a menubar status item is visible", { world, _ in
        XCTAssertTrue(world.controller.isRunning)
    }),
    ("Then", "the app does not appear in the Dock", { world, _ in
        XCTAssertTrue(world.controller.dockIconHidden)
    }),
    ("Then", "the (?:popover|panel) is visible", { world, _ in
        XCTAssertTrue(world.controller.popoverState.isVisible)
    }),
    ("Then", "the (?:popover|panel) is hidden", { world, _ in
        XCTAssertFalse(world.controller.popoverState.isVisible)
    }),
    ("Then", #"the (?:popover|panel) displays the text "(.+)""#, { world, text in
        XCTAssertEqual(world.controller.placeholderText, extractQuoted(text))
    }),
    ("Then", #"the (?:popover|panel) state is "(.+)""#, { world, text in
        XCTAssertEqual(world.controller.popoverState.isVisible ? "visible" : "hidden", extractQuoted(text))
    }),
    ("Then", #"the key is "(.+)""#, { world, text in
        XCTAssertEqual(world.lastParsedHotkey?.key, extractQuoted(text))
    }),
    ("And", #"the modifiers are "(.+)""#, { world, text in
        XCTAssertEqual(world.lastParsedHotkey?.modifiers.description, extractQuoted(text))
    }),

    // Panel layout assertions
    ("Then", "the panel appears with a fade-in animation", { world, _ in
        XCTAssertTrue(world.controller.panelAnimatesOnShow)
    }),
    ("Then", #"the panel center x is "(\d+)""#, { world, text in
        let expected = Double(extractQuoted(text)) ?? 0
        XCTAssertEqual(PanelGeometry.frame(for: screenRect(world)).midX, expected)
    }),
    ("And", #"the panel center y is "(\d+)""#, { world, text in
        let expected = Double(extractQuoted(text)) ?? 0
        XCTAssertEqual(PanelGeometry.frame(for: screenRect(world)).midY, expected)
    }),
    ("Then", #"the panel width is "(\d+)""#, { world, text in
        let expected = Double(extractQuoted(text)) ?? 0
        XCTAssertEqual(PanelGeometry.size(for: screenRect(world)).width, expected)
    }),
    ("And", #"the panel height is "(\d+)""#, { world, text in
        let expected = Double(extractQuoted(text)) ?? 0
        XCTAssertEqual(PanelGeometry.size(for: screenRect(world)).height, expected)
    }),
]

private func screenRect(_ world: AcceptanceWorld) -> CGRect {
    CGRect(x: world.screenOriginX, y: world.screenOriginY, width: world.screenWidth, height: world.screenHeight)
}

private func extractQuoted(_ text: String) -> String {
    let parts = text.components(separatedBy: "\"")
    return parts.count >= 2 ? parts[1] : ""
}

private func extractAllQuoted(_ text: String) -> [String] {
    let parts = text.components(separatedBy: "\"")
    var result: [String] = []
    var i = 1
    while i < parts.count {
        result.append(parts[i])
        i += 2
    }
    return result
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
