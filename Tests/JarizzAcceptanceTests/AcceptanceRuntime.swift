import XCTest
import JarizzCore

public enum AcceptanceRuntime {
    public static func run(world: inout AcceptanceWorld, example: [String: String], keyword: String, text: String) {
        let resolved = resolve(text, with: example)
        guard let handler = findHandler(keyword: keyword, text: resolved) else {
            XCTFail("No step handler for: [\(keyword)] \(resolved)")
            return
        }
        handler(&world, resolved)
    }

    private static func resolve(_ text: String, with example: [String: String]) -> String {
        var result = text
        for (key, value) in example {
            result = result.replacingOccurrences(of: "<\(key)>", with: value)
        }
        return result
    }

    static func findHandler(keyword: String, text: String) -> ((inout AcceptanceWorld, String) -> Void)? {
        // "And" continues the previous step's role; try all role keywords before wildcard.
        let candidates = keyword == "And"
            ? [keyword, "Given", "When", "Then", "*"]
            : [keyword, "*"]
        for kw in candidates {
            for (handlerKeyword, pattern, handler) in stepHandlerTable {
                guard handlerKeyword == kw else { continue }
                if text.range(of: "^(?:\(pattern))$", options: .regularExpression) != nil {
                    return handler
                }
            }
        }
        return nil
    }
}
