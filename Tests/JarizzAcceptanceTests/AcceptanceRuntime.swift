import XCTest
import Foundation
@testable import JarizzCore

// Acceptance test entry points are generated from Gherkin IR.
// Step handlers connecting Gherkin steps to JarizzCore go in StepHandlers.swift.
// Generated test classes are written to this target by the acceptance entrypoint generator.

extension XCTestCase {
    static var featureJSON: URL {
        guard let path = ProcessInfo.processInfo.environment["JARIZZ_FEATURE_JSON"] else {
            fatalError("JARIZZ_FEATURE_JSON environment variable not set")
        }
        return URL(fileURLWithPath: path)
    }
}
