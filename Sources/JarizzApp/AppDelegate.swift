import AppKit
import JarizzCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var eventMonitor: Any?
    private var shell = AppShellController()
    private var geminiWebView: GeminiWebView?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPanel()
        registerHotkey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        removeHotkey()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "bubble.left.and.bubble.right",
                                   accessibilityDescription: "jarizz")
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

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
        let webAdapter = GeminiWebView(url: "https://gemini.google.com/app")
        shell.configure(adapter: webAdapter)
        geminiWebView = webAdapter
        p.contentView = webAdapter.webView
        panel = p

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.dismissPanel()
                return nil
            }
            return event
        }
    }

    @objc private func statusItemClicked() {
        togglePanel()
    }

    private func togglePanel() {
        guard let p = panel else { return }
        if p.isVisible {
            dismissPanel()
        } else {
            showPanel()
        }
    }

    private func showPanel() {
        guard let p = panel else { return }
        let screen = screenForMouse()
        let frame = shell.panelFrame(for: screen.frame)
        p.setFrame(frame, display: false)
        p.alphaValue = 0
        p.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            p.animator().alphaValue = 1
        }
        shell.togglePopover()
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

    private func registerHotkey() {
        HotkeyMonitor.register(hotkey: shell.hotkey) { [weak self] in
            self?.togglePanel()
        }
    }

    private func removeHotkey() {
        HotkeyMonitor.unregister()
    }
}
