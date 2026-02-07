import XCTest
@testable import Persistence

final class InMemoryKeyValueStoreTests: XCTestCase {
    func testSetAndGetValue() throws {
        let store = InMemoryKeyValueStore()
        try store.set(["hola", "adios"], forKey: "words")
        let result = try store.get([String].self, forKey: "words")
        XCTAssertEqual(result, ["hola", "adios"])
    }
}
