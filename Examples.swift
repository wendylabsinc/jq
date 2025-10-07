import Foundation
import JQSwift

// Example usage of JQSwift

func runExamples() {
    print("=== JQSwift Examples ===\n")

    // Example 1: Simple property access
    print("Example 1: Simple property access")
    do {
        let json = """
        {"name": "Alice", "age": 30, "email": "alice@example.com"}
        """
        let name = try JQ.process(filter: ".name", input: json)
        print("Name: \(name[0])")

        let age = try JQ.process(filter: ".age", input: json)
        print("Age: \(age[0])")
    } catch {
        print("Error: \(error)")
    }

    // Example 2: Array operations
    print("\nExample 2: Array operations")
    do {
        let json = """
        [1, 2, 3, 4, 5]
        """
        let doubled = try JQ.process(filter: "map(. * 2)", input: json)
        print("Doubled: \(doubled[0])")

        let filtered = try JQ.process(filter: "map(select(. > 2))", input: json)
        print("Greater than 2: \(filtered[0])")
    } catch {
        print("Error: \(error)")
    }

    // Example 3: Complex filtering
    print("\nExample 3: Complex filtering")
    do {
        let json = """
        {
          "users": [
            {"name": "Alice", "age": 25, "active": true},
            {"name": "Bob", "age": 30, "active": false},
            {"name": "Charlie", "age": 35, "active": true}
          ]
        }
        """
        let activeUsers = try JQ.process(
            filter: ".users | map(select(.active)) | .[].name",
            input: json
        )
        print("Active users: \(activeUsers)")
    } catch {
        print("Error: \(error)")
    }

    // Example 4: Object construction
    print("\nExample 4: Object construction")
    do {
        let json = """
        {"first": "John", "last": "Doe", "age": 42}
        """
        let result = try JQ.process(
            filter: "{fullName: (.first + \" \" + .last), age: .age}",
            input: json
        )
        print("Constructed object: \(result[0])")
    } catch {
        print("Error: \(error)")
    }

    // Example 5: Using with Codable
    print("\nExample 5: Using with Codable")
    struct Person: Codable {
        let name: String
        let age: Int
    }

    do {
        let person = Person(name: "Alice", age: 30)
        let names: [String] = try JQ.process(
            filter: ".name",
            input: person,
            outputType: String.self
        )
        print("Extracted name: \(names[0])")
    } catch {
        print("Error: \(error)")
    }

    // Example 6: Error handling
    print("\nExample 6: Error handling")
    do {
        let json = """
        {"name": "test"}
        """
        _ = try JQ.process(filter: ".invalid[[[", input: json)
    } catch JQError.compileError(let msg) {
        print("Caught compile error: \(msg)")
    } catch {
        print("Unexpected error: \(error)")
    }

    print("\n=== Examples Complete ===")
}

// Uncomment to run when used as a script:
// runExamples()
