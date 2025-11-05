# JQ

[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS%20%7C%20Linux%20%7C%20Windows-blue.svg)](https://swift.org)
[![CI](https://github.com/wendylabsinc/jq/actions/workflows/ci.yml/badge.svg)](https://github.com/wendylabsinc/jq/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A Swift wrapper for [jq](https://jqlang.github.io/jq/) - a lightweight and flexible command-line JSON processor.

## Features

- Full jq 1.7.1 functionality embedded as a Swift package
- Cross-platform support (Apple platforms, Linux, and now Windows)
- Swift 6 compatible API with Codable helpers
- Zero external runtime dependencies (jq + oniguruma vendored via submodules)

## Requirements

- Swift 6.2 or later
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6+ / visionOS 1+ / Linux / Windows 10+

## Installation

### Swift Package Manager

Add JQ to your Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/wendylabsinc/jq", from: "0.5.0")
]
```

Or add it via Xcode: File ▸ Add Package Dependencies…

### Windows notes

The package now compiles natively on Windows with Swift 6.2 toolchains. No extra steps are required—just ensure the git submodule checkout is recursive (see Working Locally below).

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
    _ = try JQ.process(filter: ".invalid[[[", input: json)
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

## Working Locally (Contributors)

Swift Package Manager automatically fetches this package's git submodules when you add it as a dependency—end users do not need to do anything special.

If you're developing in this repository locally, clone with submodules or initialize them after cloning:

```bash
# Recommended: clone with submodules
git clone --recursive https://github.com/wendylabsinc/jq
cd jq

# If you already cloned without --recursive
git submodule update --init --recursive
```

## API Reference

### JQ.process(filter:input:)

```swift
static func process(filter: String, input: String) throws -> [String]
```

### JQ.process(filter:jsonData:)

```swift
static func process(filter: String, jsonData: Data) throws -> [Data]
```

### JQ.process(filter:input:outputType:)

```swift
static func process<T: Encodable, U: Decodable>(
    filter: String,
    input: T,
    outputType: U.Type
) throws -> [U]
```

## Building

```bash
swift build
swift test
swift build -c release
```

## How It Works

JQ embeds the complete jq library (v1.7.1) including oniguruma as vendored C sources. This provides:

1. Full compatibility: Same behaviour as jq CLI.
2. No external dependencies: Everything ships in this package.
3. Cross-platform: Works on Apple platforms, Linux, and Windows.
4. Performance: In-process library calls (no subprocesses).

## Architecture

```
JQ/
├── Sources/
│   ├── Cjq/              # C bridge target
│   │   ├── include/      # Public C headers and module map
│   │   ├── jq/           # git submodule: jq source + oniguruma
│   │   └── win/          # Windows compatibility shims
│   └── JQ/               # Swift wrapper API
└── Tests/
    └── JQTests/
```

## Contributing

Contributions are welcome! Please open issues or pull requests.

## License

This package wraps jq, which is licensed under the MIT License. See the [jq repository](https://github.com/jqlang/jq) for details. This wrapper is also MIT licensed.

## Acknowledgments

- [jq](https://jqlang.github.io/jq/) by Stephen Dolan and contributors
- [oniguruma](https://github.com/kkos/oniguruma)

## Resources

- [jq Manual](https://jqlang.github.io/jq/manual/)
- [jq Tutorial](https://jqlang.github.io/jq/tutorial/)
- [jq Playground](https://jqplay.org/)
