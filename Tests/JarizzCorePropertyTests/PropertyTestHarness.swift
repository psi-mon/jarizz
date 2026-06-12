import XCTest

func forAll<T>(
    _ cases: [T],
    _ label: String,
    file: StaticString = #file,
    line: UInt = #line,
    predicate: (T) -> Bool
) {
    for c in cases {
        XCTAssertTrue(predicate(c), "\(label): failed for \(c)", file: file, line: line)
    }
}
