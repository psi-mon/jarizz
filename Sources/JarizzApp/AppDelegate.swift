import AppKit
import SwiftUI
import JarizzCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: Any?
    private var shell = AppShellController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
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

    private func setupPopover() {
        let p = NSPopover()
        p.contentSize = NSSize(width: 360, height: 240)
        p.behavior = .transient
        p.contentViewController = NSHostingController(rootView: PlaceholderView())
        popover = p
    }

    @objc private func statusItemClicked() {
        togglePopover()
    }

    private func togglePopover() {
        guard let button = statusItem?.button, let p = popover else { return }
        if p.isShown {
            p.performClose(nil)
            shell.dismissPopover()
        } else {
            p.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            shell.togglePopover()
            p.contentViewController?.view.window?.makeKey()
            startEventMonitor()
        }
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.dismissPopover()
        }
    }

    private func dismissPopover() {
        popover?.performClose(nil)
        shell.dismissPopover()
        stopEventMonitor()
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func registerHotkey() {
        HotkeyMonitor.register(hotkey: shell.hotkey) { [weak self] in
            self?.togglePopover()
        }
    }

    private func removeHotkey() {
        HotkeyMonitor.unregister()
    }
}
