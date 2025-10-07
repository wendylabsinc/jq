import XCTest
@testable import JQ

final class JQTests: XCTestCase {

    func testSimpleFilter() throws {
        let input = """
        {"name": "John", "age": 30}
        """
        let results = try JQ.process(filter: ".name", input: input)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0], "\"John\"")
    }

    func testArrayFilter() throws {
        let input = """
        [1, 2, 3, 4, 5]
        """
        let results = try JQ.process(filter: ".[]", input: input)
        XCTAssertEqual(results.count, 5)
        XCTAssertEqual(results[0], "1")
        XCTAssertEqual(results[4], "5")
    }

    func testMapFilter() throws {
        let input = """
        [{"name": "Alice", "age": 25}, {"name": "Bob", "age": 30}]
        """
        let results = try JQ.process(filter: ".[].name", input: input)
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], "\"Alice\"")
        XCTAssertEqual(results[1], "\"Bob\"")
    }

    func testSelectFilter() throws {
        let input = """
        [{"name": "Alice", "age": 25}, {"name": "Bob", "age": 30}, {"name": "Charlie", "age": 20}]
        """
        let results = try JQ.process(filter: ".[] | select(.age > 21)", input: input)
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results[0].contains("Alice"))
        XCTAssertTrue(results[1].contains("Bob"))
    }

    func testObjectConstruction() throws {
        let input = """
        {"first": "John", "last": "Doe"}
        """
        let results = try JQ.process(filter: "{name: (.first + \" \" + .last)}", input: input)
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0].contains("John Doe"))
    }

    func testIdentityFilter() throws {
        let input = """
        {"foo": "bar"}
        """
        let results = try JQ.process(filter: ".", input: input)
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0].contains("foo"))
        XCTAssertTrue(results[0].contains("bar"))
    }

    func testInvalidFilter() throws {
        let input = """
        {"name": "John"}
        """
        XCTAssertThrowsError(try JQ.process(filter: "..[[[", input: input)) { error in
            guard case JQError.compileError = error else {
                XCTFail("Expected compileError")
                return
            }
        }
    }

    func testInvalidJSON() throws {
        let input = "{invalid json"
        XCTAssertThrowsError(try JQ.process(filter: ".", input: input)) { error in
            guard case JQError.invalidJSON = error else {
                XCTFail("Expected invalidJSON error")
                return
            }
        }
    }

    func testProcessWithData() throws {
        let input = """
        {"name": "John", "age": 30}
        """
        let inputData = input.data(using: .utf8)!
        let results = try JQ.process(filter: ".name", jsonData: inputData)
        XCTAssertEqual(results.count, 1)
        let resultStr = String(data: results[0], encoding: .utf8)
        XCTAssertEqual(resultStr, "\"John\"")
    }

    func testProcessWithCodable() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
        }

        let person = Person(name: "Alice", age: 25)
        let results: [String] = try JQ.process(
            filter: ".name",
            input: person,
            outputType: String.self
        )
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0], "Alice")
    }

    func testComplexFilter() throws {
        let input = """
        {
          "users": [
            {"name": "Alice", "age": 25, "city": "NYC"},
            {"name": "Bob", "age": 30, "city": "LA"},
            {"name": "Charlie", "age": 35, "city": "NYC"}
          ]
        }
        """
        let results = try JQ.process(
            filter: ".users | map(select(.city == \"NYC\")) | .[].name",
            input: input
        )
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0], "\"Alice\"")
        XCTAssertEqual(results[1], "\"Charlie\"")
    }

    func testLengthFunction() throws {
        let input = """
        [1, 2, 3, 4, 5]
        """
        let results = try JQ.process(filter: "length", input: input)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0], "5")
    }

    func testKeysFunction() throws {
        let input = """
        {"b": 2, "a": 1, "c": 3}
        """
        let results = try JQ.process(filter: "keys", input: input)
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0].contains("\"a\""))
        XCTAssertTrue(results[0].contains("\"b\""))
        XCTAssertTrue(results[0].contains("\"c\""))
    }

    func testCodableArray() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
        }

        let people = [
            Person(name: "Alice", age: 25),
            Person(name: "Bob", age: 30),
            Person(name: "Charlie", age: 35)
        ]

        // Filter array and extract names
        let names: [String] = try JQ.process(
            filter: "map(select(.age > 26)) | .[].name",
            input: people,
            outputType: String.self
        )
        XCTAssertEqual(names.count, 2)
        XCTAssertEqual(names[0], "Bob")
        XCTAssertEqual(names[1], "Charlie")
    }

    func testCodableArrayToArray() throws {
        struct Person: Codable, Equatable {
            let name: String
            let age: Int
        }

        struct SimplePerson: Codable, Equatable {
            let name: String
        }

        let people = [
            Person(name: "Alice", age: 25),
            Person(name: "Bob", age: 30)
        ]

        // Transform array to array of simpler objects
        let simplified: [[SimplePerson]] = try JQ.process(
            filter: "map({name: .name})",
            input: people,
            outputType: [SimplePerson].self
        )
        XCTAssertEqual(simplified.count, 1)
        XCTAssertEqual(simplified[0].count, 2)
        XCTAssertEqual(simplified[0][0].name, "Alice")
        XCTAssertEqual(simplified[0][1].name, "Bob")
    }

    func testInvalidJSONString() throws {
        let invalidJSON = "{this is not valid json}"
        XCTAssertThrowsError(try JQ.process(filter: ".", input: invalidJSON)) { error in
            guard case JQError.invalidJSON = error else {
                XCTFail("Expected invalidJSON error, got \(error)")
                return
            }
        }
    }

    func testJSONStringParsing() throws {
        // Valid JSON should parse successfully
        let validJSON = """
        {"name": "test", "value": 42}
        """
        let results = try JQ.process(filter: ".", input: validJSON)
        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results[0].contains("test"))
        XCTAssertTrue(results[0].contains("42"))
    }
}
