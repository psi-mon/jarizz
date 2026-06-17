import XCTest
import JarizzCore
import JarizzCoreTestHelpers

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
    ("Given", #"a web provider is configured with URL "(.+)""#, { world, text in
        let adapter = MockWebProviderAdapter(url: extractQuoted(text))
        world.webAdapter = adapter
        world.controller.configure(adapter: adapter)
    }),
    ("Given", "the network is unavailable", { world, _ in
        world.controller.setNetworkUnavailable()
    }),
    // Settings Given steps
    ("Given", "the app is launching for the first time with no saved settings", { world, _ in
        let store = InMemorySettingsStore()
        world.settingsStore = store
        world.settingsCtrl = SettingsController(store: store)
        world.controller = AppShellController()
    }),
    ("Given", "no providers are configured", { world, _ in
        // settingsCtrl starts empty by default; no-op if already empty
    }),
    ("Given", "the Settings window is open on the Providers tab", { _, _ in }),
    ("Given", "the Settings window is open on the General tab", { _, _ in }),
    ("Given", "the Settings window is open", { _, _ in }),
    ("Given", #"a provider with name "(.+)" and URL "(.+)" exists"#, { world, text in
        let parts = extractAllQuoted(text)
        try? world.settingsCtrl.addProvider(name: parts[safe: 0] ?? "", url: parts[safe: 1] ?? "")
    }),
    ("Given", #"a provider with name "(.+)" exists"#, { world, text in
        let name = extractQuoted(text)
        try? world.settingsCtrl.addProvider(name: name, url: "https://\(name.lowercased()).example.com")
    }),
    ("Given", #"a provider with name "(.+)" and URL "(.+)" is starred"#, { world, text in
        let parts = extractAllQuoted(text)
        let name = parts[safe: 0] ?? ""
        let url = parts[safe: 1] ?? ""
        try? world.settingsCtrl.addProvider(name: name, url: url)
        world.settingsCtrl.starProvider(named: name)
    }),
    ("Given", #"a provider with name "(.+)" is starred"#, { world, text in
        let name = extractQuoted(text)
        try? world.settingsCtrl.addProvider(name: name, url: "https://\(name.lowercased()).example.com")
        world.settingsCtrl.starProvider(named: name)
    }),
    ("Given", #"a provider with name "(.+)" and URL "(.+)" has been added"#, { world, text in
        let parts = extractAllQuoted(text)
        try? world.settingsCtrl.addProvider(name: parts[safe: 0] ?? "", url: parts[safe: 1] ?? "")
    }),
    ("Given", #"the provider "(.+)" is starred"#, { world, text in
        let name = extractQuoted(text)
        try? world.settingsCtrl.addProvider(name: name, url: "https://\(name.lowercased()).example.com")
        world.settingsCtrl.starProvider(named: name)
    }),
    ("Given", "no provider is starred", { _, _ in }),
    ("Given", #"the first provider in the list has URL "(.+)""#, { world, text in
        try? world.settingsCtrl.addProvider(name: "First", url: extractQuoted(text))
    }),
    ("Given", #"a provider with URL "(.+)" already exists"#, { world, text in
        try? world.settingsCtrl.addProvider(name: "Existing", url: extractQuoted(text))
    }),
    ("Given", #"the global hotkey has been set to "(.+)""#, { world, text in
        world.settingsCtrl.setHotkey(extractQuoted(text))
    }),
    ("Given", #"the panel size has been set to "(\d+)" percent"#, { world, text in
        world.settingsCtrl.setPanelSizePercent(Int(extractQuoted(text)) ?? 50)
    }),
    // Manual-only stubs
    ("Given", "Gemini is loaded and the input field is present", { _, _ in }),
    ("Given", "the user is not signed in to Google", { _, _ in }),
    ("Given", "the user is not signed in to Google in the panel", { _, _ in }),
    ("Given", "the user has initiated Google sign-in", { _, _ in }),
    ("Given", "the user is signed in to Google inside the panel", { _, _ in }),

    // Action steps (When)
    ("When", "the app launches", { world, _ in
        world.controller.launch()
    }),
    ("When", #"the user presses the global hotkey "(.+)""#, { world, _ in
        world.controller.togglePopover()
    }),
    // Settings When steps
    ("When", #"the user sets the global hotkey to "(.+)""#, { world, text in
        world.settingsCtrl.setHotkey(extractQuoted(text))
    }),
    ("When", #"the user sets the panel size to "(\d+)" percent"#, { world, text in
        world.settingsCtrl.setPanelSizePercent(Int(extractQuoted(text)) ?? 50)
    }),
    ("When", "the app is restarted", { world, _ in
        world.settingsCtrl.reload()
        world.controller = AppShellController()
    }),
    ("When", "the user shows the panel", { world, _ in
        if let provider = world.settingsCtrl.activeProvider {
            let adapter = MockWebProviderAdapter(url: provider.url)
            world.webAdapter = adapter
            world.controller.configure(adapter: adapter)
        }
        world.controller.togglePopover()
    }),
    ("When", #"the user adds a provider with name "(.+)" and URL "(.+)""#, { world, text in
        let parts = extractAllQuoted(text)
        try? world.settingsCtrl.addProvider(name: parts[safe: 0] ?? "", url: parts[safe: 1] ?? "")
    }),
    ("When", #"the user removes the provider "(.+)""#, { world, text in
        world.settingsCtrl.removeProvider(named: extractQuoted(text))
    }),
    ("When", #"the user edits the provider name to "(.+)" and URL to "(.+)""#, { world, text in
        let parts = extractAllQuoted(text)
        let newName = parts[safe: 0] ?? ""
        let newURL = parts[safe: 1] ?? ""
        if let id = world.settingsCtrl.settings.providers.first?.id {
            try? world.settingsCtrl.editProvider(id: id, name: newName, url: newURL)
        }
    }),
    ("When", #"the user stars the provider "(.+)""#, { world, text in
        world.settingsCtrl.starProvider(named: extractQuoted(text))
    }),
    ("When", #"the user tries to add a provider with name "(.*)" and URL "(.+)""#, { world, text in
        let parts = extractAllQuoted(text)
        do {
            try world.settingsCtrl.addProvider(name: parts[safe: 0] ?? "", url: parts[safe: 1] ?? "")
        } catch let err as ProviderError {
            world.lastProviderError = err
        } catch {}
    }),
    // Manual-only action stubs
    ("When", "the user completes Google sign-in inside the panel", { _, _ in }),
    ("When", "Google authentication requires a secondary window", { _, _ in }),
    ("When", "the user initiates Google sign-in", { _, _ in }),
    ("When", "jarizz presents a system authentication session", { _, _ in }),
    ("When", "the user initiates passkey sign-in", { _, _ in }),
    ("When", "the user quits the app", { _, _ in }),
    ("When", "the user launches the app", { _, _ in }),
    ("When", #"the user right-clicks the menubar icon"#, { _, _ in }),
    ("When", #"the user selects "(.+)" from the context menu"#, { _, _ in }),
    ("When", #"the user moves the panel size slider to "(\d+)" percent"#, { _, _ in }),
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
    ("Then", #"the panel width is "(\d+)""#, assertPanelWidth),
    ("And", #"the panel height is "(\d+)""#, assertPanelHeight),
    ("Then", #"the panel content width is "(\d+)""#, assertPanelWidth),
    ("And", #"the panel content height is "(\d+)""#, assertPanelHeight),

    // Web provider assertions
    ("Then", #"the web provider has navigated to "(.+)""#, { world, text in
        XCTAssertEqual(world.webAdapter?.lastNavigatedURL, extractQuoted(text))
    }),
    ("Then", #"the web provider navigation count is "(\d+)""#, { world, text in
        XCTAssertEqual(world.webAdapter?.navigationCount, Int(extractQuoted(text)) ?? -1)
    }),
    ("Then", "the web provider uses persistent session storage", { world, _ in
        XCTAssertTrue(world.webAdapter?.usesPersistentSessionStorage ?? false)
    }),
    ("Then", "the web provider handles new windows inside the app", { world, _ in
        XCTAssertTrue(world.webAdapter?.handlesNewWindowsInApp ?? false)
    }),
    ("Then", "the web provider auth session is not ephemeral", { world, _ in
        XCTAssertTrue(world.webAdapter?.authSessionIsNonEphemeral ?? false)
    }),
    ("Then", "the web provider focuses the input field on show", { world, _ in
        XCTAssertTrue(world.webAdapter?.focusesInputFieldOnShow ?? false)
    }),
    ("Then", #"the panel displays "(.+)""#, { world, text in
        let expected = extractQuoted(text)
        let msg = world.controller.networkErrorMessage ?? world.settingsCtrl.panelContentMessage
        XCTAssertEqual(msg, expected)
    }),

    // Settings assertions
    ("Then", #"the global hotkey is "(.+)""#, { world, text in
        XCTAssertEqual(world.settingsCtrl.settings.hotkey, extractQuoted(text))
    }),
    ("Then", #"the panel size is "(\d+)" percent of the screen frame"#, { world, text in
        XCTAssertEqual(world.settingsCtrl.settings.panelSizePercent, Int(extractQuoted(text)) ?? -1)
    }),
    ("Then", #"the provider "(.+)" with URL "(.+)" is in the provider list"#, { world, text in
        let parts = extractAllQuoted(text)
        let name = parts[safe: 0] ?? ""
        let url = parts[safe: 1] ?? ""
        XCTAssertTrue(world.settingsCtrl.settings.providers.contains { $0.name == name && $0.url == url })
    }),
    ("Then", #"the provider "(.+)" is not in the provider list"#, { world, text in
        XCTAssertFalse(world.settingsCtrl.settings.providers.contains { $0.name == extractQuoted(text) })
    }),
    ("Then", #"the provider "(.+)" is starred"#, { world, text in
        XCTAssertTrue(world.settingsCtrl.settings.providers.first { $0.name == extractQuoted(text) }?.starred ?? false)
    }),
    ("And", #"the provider "(.+)" is not starred"#, { world, text in
        XCTAssertFalse(world.settingsCtrl.settings.providers.first { $0.name == extractQuoted(text) }?.starred ?? true)
    }),
    ("Then", "the provider is not added", { world, _ in
        XCTAssertNotNil(world.lastProviderError)
    }),
    ("And", #"the error "(.+)" is shown"#, { world, text in
        let expected = extractQuoted(text)
        switch world.lastProviderError {
        case .invalidURL: XCTAssertEqual(expected, "Invalid URL")
        case .duplicateURL: XCTAssertEqual(expected, "URL already in use")
        case .nameRequired: XCTAssertEqual(expected, "Name is required")
        case nil: XCTFail("Expected a provider error but got none")
        }
    }),
    // Manual-only assertion stubs
    ("Then", "the user is signed in to Google inside the panel", { _, _ in }),
    ("Then", "jarizz presents a system authentication session for Google sign-in", { _, _ in }),
    ("And", "after sign-in completes the user is signed in to Google in the panel", { _, _ in }),
    ("Then", "the session can use an existing signed-in Google account from the system browser", { _, _ in }),
    ("Then", "jarizz presents a system authentication session that supports passkeys", { _, _ in }),
    ("Then", "the Gemini input field has focus", { _, _ in }),
    ("Then", "the secondary window opens inside the app", { _, _ in }),
    ("And", "the user can complete sign-in without switching to an external browser", { _, _ in }),
    ("Then", "a context menu appears containing \"Settings…\"", { _, _ in }),
    ("And", "the context menu contains \"Quit jarizz\"", { _, _ in }),
    ("Then", "the Settings window is visible", { _, _ in }),
    ("Then", #"a transparent overlay is shown at "(\d+)" percent of the current screen"#, { _, _ in }),
]

private func assertPanelWidth(_ world: inout AcceptanceWorld, _ text: String) {
    let expected = Double(extractQuoted(text)) ?? 0
    XCTAssertEqual(PanelGeometry.size(for: screenRect(world)).width, expected)
}

private func assertPanelHeight(_ world: inout AcceptanceWorld, _ text: String) {
    let expected = Double(extractQuoted(text)) ?? 0
    XCTAssertEqual(PanelGeometry.size(for: screenRect(world)).height, expected)
}

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
