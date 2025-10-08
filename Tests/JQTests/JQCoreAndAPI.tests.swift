import Foundation
import Testing
@testable import JQ

@Suite("Core JQ API")
struct JQCoreTests {

    @Test("Simple property access")
    func simpleProperty() throws {
        let input = "{" + "\"name\": \"John\", \"age\": 30}"
        let results = try JQ.process(filter: ".name", input: input)
        #expect(results == ["\"John\""])
    }

    @Test("Identity filter")
    func identity() throws {
        let input = "{" + "\"foo\": \"bar\"}"
        let results = try JQ.process(filter: ".", input: input)
        #expect(results.count == 1)
        #expect(results[0].contains("\"foo\""))
        #expect(results[0].contains("\"bar\""))
    }

    @Test("Array iteration emits multiple outputs")
    func arrayIteration() throws {
        let input = "[1, 2, 3, 4, 5]"
        let results = try JQ.process(filter: ".[]", input: input)
        #expect(results.count == 5)
        #expect(results.first == "1")
        #expect(results.last == "5")
    }

    @Test("Object construction")
    func objectConstruction() throws {
        let input = "{" + "\"first\": \"John\", \"last\": \"Doe\"}"
        let results = try JQ.process(filter: "{name: (.first + \" \" + .last)}", input: input)
        #expect(results.count == 1)
        #expect(results[0].contains("John Doe"))
    }

    @Test("Length and keys functions")
    func lengthAndKeys() throws {
        let arr = try JQ.process(filter: "length", input: "[1,2,3,4,5]")
        #expect(arr == ["5"])

        let obj = try JQ.process(filter: "keys | sort", input: "{\"b\":2,\"a\":1,\"c\":3}")
        #expect(obj.count == 1)
        #expect(obj[0].contains("\"a\""))
        #expect(obj[0].contains("\"b\""))
        #expect(obj[0].contains("\"c\""))
    }
}

@Suite("Typed API (Codable)")
struct JQTypedAPITests {
    struct Person: Codable, Equatable { let name: String; let age: Int }
    struct SimplePerson: Codable, Equatable { let name: String }

    @Test("Decode to scalar types")
    func decodeScalars() throws {
        let input = Person(name: "Alice", age: 25)
        let names: [String] = try JQ.process(filter: ".name", input: input, outputType: String.self)
        #expect(names == ["Alice"]) 

        let ages: [Int] = try JQ.process(filter: ".age", input: input, outputType: Int.self)
        #expect(ages == [25])
    }

    @Test("Map to array of objects")
    func decodeArrayMapping() throws {
        let people = [Person(name: "Alice", age: 25), Person(name: "Bob", age: 30)]
        let simplified: [[SimplePerson]] = try JQ.process(
            filter: "map({name: .name})",
            input: people,
            outputType: [SimplePerson].self
        )
        #expect(simplified.count == 1)
        #expect(simplified[0].count == 2)
        #expect(simplified[0][0] == SimplePerson(name: "Alice"))
        #expect(simplified[0][1] == SimplePerson(name: "Bob"))
    }

    @Test("JSON Data in/out")
    func dataIO() throws {
        let data = "{\"name\": \"John\", \"age\": 33}".data(using: .utf8)!
        let results = try JQ.process(filter: ".name", jsonData: data)
        #expect(results.count == 1)
        #expect(String(data: results[0], encoding: .utf8) == "\"John\"")
    }
}

@Suite("Errors and edge cases")
struct JQErrorTests {

    @Test("Invalid JSON triggers invalidJSON error")
    func invalidJSON() {
        let bad = "{this is not valid json}"
        #expect(throws: JQError.self) {
            _ = try JQ.process(filter: ".", input: bad)
        }
    }

    @Test("Invalid filter triggers compileError")
    func invalidFilter() {
        let input = "{" + "\"name\": \"John\"}"
        #expect(throws: JQError.self) {
            _ = try JQ.process(filter: ".invalid[[[", input: input)
        }
    }

    @Test("Execution error via error()")
    func executionError() {
        #expect(throws: JQError.self) {
            _ = try JQ.process(filter: "error(\"boom\")", input: "null")
        }
    }

    @Test("Regex: match/test with Oniguruma")
    func regex() throws {
        let input = "{\"text\": \"abc123xyz\"}"
        let hasDigits = try JQ.process(filter: ".text | test(\"[0-9]+\")", input: input)
        #expect(hasDigits == ["true"]) // jq booleans render as unquoted

        let captures = try JQ.process(filter: ".text | match(\"(?<d>\\\\d+)\").captures[0].string", input: input)
        #expect(captures == ["\"123\""])
    }

    @Test("Unicode and large numbers")
    func unicodeAndNumbers() throws {
        let input = "{\"s\": \"😀 café\", \"n\": 9007199254740991}"
        let s = try JQ.process(filter: ".s", input: input)
        #expect(s == ["\"😀 café\""])

        let n = try JQ.process(filter: ".n", input: input)
        #expect(n == ["9007199254740991"]) // 2^53-1
    }
}

