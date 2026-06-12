import Foundation
import XCTest

struct FeatureStep: Decodable {
    let keyword: String
    let text: String
    let parameters: [String]?
}

struct FeatureScenario: Decodable {
    let name: String
    let steps: [FeatureStep]
    let examples: [[String: String]]?
}

struct FeatureIR: Decodable {
    let name: String
    let background: [FeatureStep]?
    let scenarios: [FeatureScenario]

    static func load(from path: String) throws -> FeatureIR {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try JSONDecoder().decode(FeatureIR.self, from: data)
    }
}

// Loads examples at runtime: checks JARIZZ_FEATURE_JSON first, falls back to compiledIRPath.
// compiledIRPath is relative to the package root (the working directory for `swift test`).
// Regular scenarios (not Scenario Outlines) have no examples; returns [:] for those — correct,
// since their step text contains no <placeholder> tokens needing substitution.
func runtimeExample(compiledIRPath: String, scenarioIndex: Int, exampleIndex: Int) -> [String: String] {
    let path = ProcessInfo.processInfo.environment["JARIZZ_FEATURE_JSON"] ?? compiledIRPath
    do {
        let ir = try FeatureIR.load(from: path)
        guard scenarioIndex < ir.scenarios.count else {
            XCTFail("runtimeExample: scenarioIndex \(scenarioIndex) out of range in \(path)")
            return [:]
        }
        let examples = ir.scenarios[scenarioIndex].examples ?? []
        guard !examples.isEmpty else { return [:] }
        guard exampleIndex < examples.count else {
            XCTFail("runtimeExample: exampleIndex \(exampleIndex) out of range in \(path)")
            return [:]
        }
        return examples[exampleIndex]
    } catch {
        XCTFail("runtimeExample: failed to load IR from \(path): \(error)")
        return [:]
    }
}
