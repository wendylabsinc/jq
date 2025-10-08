# JQ

A Swift wrapper for [jq](https://jqlang.github.io/jq/) - a lightweight and flexible command-line JSON processor.

## Features

- ✅ Full jq 1.7.1 functionality embedded as a Swift package
- ✅ Cross-platform support (macOS, iOS, tvOS, watchOS, visionOS, Linux)
- ✅ Swift 6 compatible API
- ✅ Type-safe Swift API with Codable support
- ✅ Zero external dependencies (jq and oniguruma embedded via git submodules)

## Requirements

- Swift 6.2 or later
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6+ / visionOS 1+ / Linux

## Installation

### Swift Package Manager

Add JQ to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/wendylabsinc/jq", from: "0.3.0")
]
```

Or add it via Xcode: File → Add Package Dependencies

### Clone with Submodules

Since this package uses git submodules for jq and oniguruma:

```bash
git clone --recursive https://github.com/wendylabsinc/jq
cd jq
```

If you already cloned without `--recursive`:

```bash
git submodule update --init --recursive
```

## Usage

### Basic Examples

```swift
import JQ

// Simple property access
let json = """
{"name": "Alice", "age": 30}
"""
let results = try JQ.process(filter: ".name", input: json)
print(results[0])  // "Alice"

// Array filtering
let arrayJson = """
[1, 2, 3, 4, 5]
"""
let numbers = try JQ.process(filter: ".[]", input: arrayJson)
// numbers: ["1", "2", "3", "4", "5"]

// Complex filtering
let usersJson = """
{
  "users": [
    {"name": "Alice", "age": 25, "city": "NYC"},
    {"name": "Bob", "age": 30, "city": "LA"},
    {"name": "Charlie", "age": 35, "city": "NYC"}
  ]
}
"""
let nycUsers = try JQ.process(
    filter: ".users | map(select(.city == \"NYC\")) | .[].name",
    input: usersJson
)
// nycUsers: ["\"Alice\"", "\"Charlie\""]
```

### Working with Data

```swift
import Foundation
import JQ

let jsonData = """
{"name": "John", "age": 30}
""".data(using: .utf8)!

let results = try JQ.process(filter: ".name", jsonData: jsonData)
let name = String(data: results[0], encoding: .utf8)
```

### Working with Codable Types

```swift
struct Person: Codable {
    let name: String
    let age: Int
}

let person = Person(name: "Alice", age: 25)

// Extract specific field
let names: [String] = try JQ.process(
    filter: ".name",
    input: person,
    outputType: String.self
)
print(names[0])  // "Alice"
```

### Error Handling

```swift
do {
    let results = try JQ.process(filter: ".invalid[[[", input: json)
} catch JQError.compileError(let msg) {
    print("Filter compilation failed: \(msg)")
} catch JQError.invalidJSON(let msg) {
    print("Invalid JSON: \(msg)")
} catch JQError.executionError(let msg) {
    print("Execution error: \(msg)")
} catch {
    print("Unexpected error: \(error)")
}
```

## API Reference

### JQ.process(filter:input:)

```swift
static func process(filter: String, input: String) throws -> [String]
```

Process JSON string with a jq filter.

- **Parameters:**
  - `filter`: jq filter expression (e.g., ".foo", ".[] | select(.age > 21)")
  - `input`: JSON string to process
- **Returns:** Array of JSON strings (one for each output)
- **Throws:** `JQError` if compilation or execution fails

### JQ.process(filter:jsonData:)

```swift
static func process(filter: String, jsonData: Data) throws -> [Data]
```

Process JSON data with a jq filter.

### JQ.process(filter:input:outputType:)

```swift
static func process<T: Encodable, U: Decodable>(
    filter: String,
    input: T,
    outputType: U.Type
) throws -> [U]
```

Process Codable input with a jq filter and decode to Codable output.

## Building

```bash
# Build the package
swift build

# Run tests
swift test

# Build in release mode
swift build -c release
```

## How It Works

JQSwift embeds the complete jq library (v1.7.1) including its regex engine (oniguruma) as C sources compiled directly into your Swift package. This approach provides:

1. **Full compatibility**: All jq features work exactly as in the command-line tool
2. **No external dependencies**: Everything is bundled in the package
3. **Cross-platform**: Works on all Swift-supported platforms
4. **Performance**: In-process library calls with no subprocess overhead

The package uses git submodules to track upstream jq releases, making updates straightforward.

## Architecture

```
JQ/
├── Sources/
│   ├── Cjq/              # C library wrapper
│   │   ├── include/      # Public C headers and module map
│   │   └── jq/           # Git submodule: jq source + oniguruma
│   └── JQ/               # Swift wrapper API
├── Tests/
│   └── JQTests/
└── Package.swift
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package wraps jq, which is licensed under the MIT License. See the [jq repository](https://github.com/jqlang/jq) for details.

## Acknowledgments

- [jq](https://jqlang.github.io/jq/) - The amazing JSON processor by Stephen Dolan and contributors
- [oniguruma](https://github.com/kkos/oniguruma) - Regular expression library

## Resources

- [jq Manual](https://jqlang.github.io/jq/manual/)
- [jq Tutorial](https://jqlang.github.io/jq/tutorial/)
- [jq Playground](https://jqplay.org/)
