import Carbon
import JarizzCore

enum HotkeyMonitor {
    private static var eventHotKeyRef: EventHotKeyRef?
    private static var eventHandler: EventHandlerRef?
    private static var callback: (() -> Void)?

    static func register(hotkey: Hotkey, action: @escaping () -> Void) {
        callback = action
        let keyCode = carbonKeyCode(for: hotkey.key)
        let modifiers = carbonModifiers(for: hotkey.modifiers)

        let hotkeyID = EventHotKeyID(signature: OSType(0x4A525A5A), id: 1) // 'JRZZ'
        var ref: EventHotKeyRef?
        RegisterEventHotKey(keyCode, modifiers, hotkeyID, GetApplicationEventTarget(), 0, &ref)
        eventHotKeyRef = ref

        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ -> OSStatus in
            HotkeyMonitor.callback?()
            return noErr
        }, 1, &spec, nil, &eventHandler)
    }

    static func unregister() {
        if let ref = eventHotKeyRef { UnregisterEventHotKey(ref) }
        if let handler = eventHandler { RemoveEventHandler(handler) }
        eventHotKeyRef = nil
        eventHandler = nil
        callback = nil
    }

    private static func carbonKeyCode(for key: String) -> UInt32 {
        let map: [String: UInt32] = [
            "space": 49, "Space": 49,
            "]": 30, "[": 33, "\\": 42,
            "a": 0, "b": 11, "c": 8, "d": 2, "e": 14, "f": 3, "g": 5,
            "h": 4, "i": 34, "j": 38, "k": 40, "l": 37, "m": 46, "n": 45,
            "o": 31, "p": 35, "q": 12, "r": 15, "s": 1, "t": 17, "u": 32,
            "v": 9, "w": 13, "x": 7, "y": 16, "z": 6,
            "return": 36, "Return": 36, "escape": 53, "Escape": 53,
            "tab": 48, "Tab": 48, "delete": 51,
            "F1": 122, "F2": 120, "F3": 99, "F4": 118, "F5": 96,
            "F6": 97, "F7": 98, "F8": 100, "F9": 101, "F10": 109,
        ]
        return map[key] ?? 0
    }

    // Use intersection (not contains) so that a single sided modifier (e.g. .leftShift)
    // still matches the side-agnostic Carbon flag (.shift = [.leftShift, .rightShift]).
    private static func carbonModifiers(for modifiers: Hotkey.Modifiers) -> UInt32 {
        var result: UInt32 = 0
        if !modifiers.intersection(.control).isEmpty { result |= UInt32(controlKey) }
        if !modifiers.intersection(.option).isEmpty  { result |= UInt32(optionKey) }
        if !modifiers.intersection(.command).isEmpty { result |= UInt32(cmdKey) }
        if !modifiers.intersection(.shift).isEmpty   { result |= UInt32(shiftKey) }
        return result
    }
}
