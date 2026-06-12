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
    ("Given", "the popover is hidden", { world, _ in
        if world.controller.popoverState.isVisible { world.controller.dismissPopover() }
    }),
    ("Given", "the popover is visible", { world, _ in
        if !world.controller.popoverState.isVisible { world.controller.togglePopover() }
    }),
    ("Given", #"the popover state is "(.+)""#, { world, text in
        let inner = extractQuoted(text)
        world.controller = AppShellController()
        if inner == "visible" { world.controller.togglePopover() }
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
    ("When", "the user clicks outside the popover", { world, _ in
        world.controller.dismissPopover()
    }),
    ("When", "the popover is toggled", { world, _ in
        world.controller.togglePopover()
    }),
    ("When", #"the hotkey string "(.+)" is parsed"#, { world, text in
        let inner = extractQuoted(text)
        do {
            world.lastParsedHotkey = try HotkeyDescription(string: inner)
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
    ("Then", "the popover is visible", { world, _ in
        XCTAssertTrue(world.controller.popoverState.isVisible)
    }),
    ("Then", "the popover is hidden", { world, _ in
        XCTAssertFalse(world.controller.popoverState.isVisible)
    }),
    ("Then", #"the popover displays the text "(.+)""#, { world, text in
        XCTAssertEqual(world.controller.placeholderText, extractQuoted(text))
    }),
    ("Then", #"the popover state is "(.+)""#, { world, text in
        XCTAssertEqual(world.controller.popoverState.rawValue, extractQuoted(text))
    }),
    ("Then", #"the key is "(.+)""#, { world, text in
        XCTAssertEqual(world.lastParsedHotkey?.key, extractQuoted(text))
    }),
    ("And", #"the modifiers are "(.+)""#, { world, text in
        XCTAssertEqual(world.lastParsedHotkey?.modifiersDescription, extractQuoted(text))
    }),
]

private func extractQuoted(_ text: String) -> String {
    let parts = text.components(separatedBy: "\"")
    return parts.count >= 2 ? parts[1] : ""
}
