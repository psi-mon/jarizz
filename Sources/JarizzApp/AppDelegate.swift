import AppKit
import SwiftUI
import JarizzCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var eventMonitor: Any?
    private var shell = AppShellController()
    private var webView: GeminiWebView?
    private let store = JSONSettingsStore()
    private lazy var settingsViewModel = SettingsViewModel(store: store)
    private var settingsWindowController: NSWindowController?
    private var providerWebViews: [String: GeminiWebView] = [:]
    private var panelRailHosting: NSHostingView<ProviderRailView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPanel()
        registerHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        removeHotkey()
    }

    // MARK: - Status item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "bubble.left.and.bubble.right",
                               accessibilityDescription: "jarizz")
        button.action = #selector(statusItemClicked)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseDown])
    }

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseDown {
            showContextMenu()
        } else {
            togglePanel()
        }
    }

    private func showContextMenu() {
        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: "")
        settingsItem.target = self
        let quitItem = NSMenuItem(title: "Quit jarizz", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        let menu = NSMenu()
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    // MARK: - Settings window

    @objc private func openSettings() {
        dismissPanel()
        if settingsWindowController == nil {
            let win = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            win.title = "jarizz Settings"
            win.level = .floating
            win.contentView = NSHostingView(rootView: SettingsView(
                vm: settingsViewModel,
                onHotkeyChange: { [weak self] in self?.updateHotkey() },
                onProvidersChange: { [weak self] in self?.updatePanelContent() }
            ))
            win.center()
            settingsWindowController = NSWindowController(window: win)
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    // MARK: - Panel setup and content

    private func setupPanel() {
        let p = NSPanel(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        p.isFloatingPanel = true
        p.titleVisibility = .hidden
        p.titlebarAppearsTransparent = true
        p.isMovableByWindowBackground = true
        p.level = .floating
        p.animationBehavior = .utilityWindow
        p.hidesOnDeactivate = false
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel = p
        updatePanelContent()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 {
                self?.dismissPanel()
                return nil
            }
            if event.keyCode == 48 && event.modifierFlags.contains(.control) {
                self?.cycleToNextProvider()
                return nil
            }
            return event
        }
    }

    private func cachedAdapter(for url: String) -> GeminiWebView {
        if let existing = providerWebViews[url] { return existing }
        let adapter = GeminiWebView(url: url)
        providerWebViews[url] = adapter
        return adapter
    }

    private func wireAdapter(_ adapter: GeminiWebView, to p: NSPanel) {
        shell.configure(adapter: adapter)
        webView = adapter

        let container = NSView()
        container.wantsLayer = true
        container.autoresizingMask = [.width, .height]

        adapter.webView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(adapter.webView)
        NSLayoutConstraint.activate([
            adapter.webView.topAnchor.constraint(equalTo: container.topAnchor),
            adapter.webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            adapter.webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            adapter.webView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        if panelRailHosting == nil {
            panelRailHosting = NSHostingView(rootView: ProviderRailView(
                vm: settingsViewModel,
                onSelectProvider: { [weak self] name in self?.selectProviderByName(name) }
            ))
        }
        let railHosting = panelRailHosting!
        railHosting.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(railHosting)
        NSLayoutConstraint.activate([
            railHosting.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            railHosting.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        p.contentView = container
    }

    private func selectProviderByName(_ name: String) {
        settingsViewModel.controller.selectProvider(named: name)
        activateCurrentProvider()
    }

    private func cycleToNextProvider() {
        settingsViewModel.controller.cycleProvider()
        activateCurrentProvider(force: true)
    }

    private func activateCurrentProvider(force: Bool = false) {
        guard let provider = settingsViewModel.controller.currentProvider,
              let p = panel else { return }
        let adapter = cachedAdapter(for: provider.url)
        if adapter.navigationCount == 0 {
            adapter.navigate(to: provider.url)
        }
        if force || webView !== adapter {
            wireAdapter(adapter, to: p)
        }
        DispatchQueue.main.async { [weak self] in self?.webView?.focusInputField() }
    }

    private func updatePanelContent() {
        guard let p = panel else { return }
        settingsViewModel.controller.resetCurrentToActiveProvider()
        if let provider = settingsViewModel.controller.currentProvider {
            let adapter = cachedAdapter(for: provider.url)
            if webView !== adapter {
                shell = AppShellController()
                wireAdapter(adapter, to: p)
            }
        } else {
            shell = AppShellController()
            webView = nil
            p.contentView = NSHostingView(rootView: NoProviderView())
        }
    }

    // MARK: - Panel toggle

    private func togglePanel() {
        guard let p = panel else { return }
        if p.isVisible { dismissPanel() } else { showPanel() }
    }

    private func showPanel() {
        guard let p = panel else { return }
        updatePanelContent()
        let screen = screenForMouse()
        let sizePercent = settingsViewModel.controller.settings.panelSizePercent
        let factor = CGFloat(sizePercent) / 100.0
        let size = CGSize(width: screen.frame.width * factor, height: screen.frame.height * factor)
        let origin = PanelGeometry.origin(for: size, in: screen.frame)
        p.setFrame(CGRect(origin: origin, size: size), display: false)
        p.alphaValue = 0
        p.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            p.animator().alphaValue = 1
        }
        shell.togglePopover()
        DispatchQueue.main.async { [weak self] in self?.webView?.focusInputField() }
        startEventMonitor()
    }

    private func dismissPanel() {
        panel?.orderOut(nil)
        shell.dismissPopover()
        stopEventMonitor()
    }

    private func screenForMouse() -> NSScreen {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first {
            NSMouseInRect(mouseLocation, $0.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens[0]
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismissPanel()
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    // MARK: - Hotkey

    private func registerHotkey() {
        let hotkeyString = settingsViewModel.controller.settings.hotkey
        guard let hotkey = try? Hotkey.parse(hotkeyString) else { return }
        HotkeyMonitor.register(hotkey: hotkey) { [weak self] in
            self?.togglePanel()
        }
    }

    private func removeHotkey() {
        HotkeyMonitor.unregister()
    }

    private func updateHotkey() {
        removeHotkey()
        registerHotkey()
    }
}
