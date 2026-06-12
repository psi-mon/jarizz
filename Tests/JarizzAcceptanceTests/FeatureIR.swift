import Foundation

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

// Loads examples at runtime: checks JARIZZ_FEATURE_JSON env var first, falls back to compiledIRPath.
func runtimeExample(compiledIRPath: String, scenarioIndex: Int, exampleIndex: Int) -> [String: String] {
    let path = ProcessInfo.processInfo.environment["JARIZZ_FEATURE_JSON"] ?? compiledIRPath
    guard let ir = try? FeatureIR.load(from: path),
          scenarioIndex < ir.scenarios.count else { return [:] }
    let scenario = ir.scenarios[scenarioIndex]
    let examples = scenario.examples ?? [[:]]
    guard exampleIndex < examples.count else { return [:] }
    return examples[exampleIndex]
}
