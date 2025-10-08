# ``JQ``

Swift wrapper around the jq JSON processor.

Use the static helpers on ``JQ/JQ`` to evaluate jq filters against JSON text, `Data`, or `Codable` values.

## Installation

### Swift Package Manager (SPM)

Add the package to your `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "YourApp",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)
    ],
    dependencies: [
        .package(url: "https://github.com/wendylabsinc/jq", from: "0.3.1")
    ],
    targets: [
        .executableTarget(
            name: "YourApp",
            dependencies: [
                .product(name: "JQ", package: "jq")
            ]
        )
    ]
)
```

In Xcode: File → Add Packages → search or paste the URL `https://github.com/wendylabsinc/jq`.

> Note: Swift Package Manager automatically fetches this package's git submodules. Contributors working directly in this repository should clone with `--recursive`.

## Usage

### Using JSON strings

```swift
import JQ

let json = "{" + "\"name\":\"Alice\",\"age\":30" + "}"
let outputs = try JQ.process(filter: ".name", input: json)
// outputs == ["\"Alice\""]
```

### Using JSON `Data`

```swift
import JQ
import Foundation

let data = Data("{\"nums\":[1,2,3,4,5]}".utf8)
let outputs = try JQ.process(filter: ".nums[] | select(. > 3)", jsonData: data)
// outputs contains Data for "4" and "5"
```

### Using `Codable`

You can encode `Encodable` inputs and decode jq results to a `Decodable` type.

```swift
import JQ

struct Person: Codable { let name: String; let age: Int }
let people = [
  Person(name: "Alice", age: 20),
  Person(name: "Bob",   age: 30)
]

let names: [String] = try JQ.process(
  filter: "[.[] | select(.age >= 21) | .name] | .[]",
  input: people,
  outputType: String.self
)
// names == ["Bob"]
```

### Error handling

```swift
do {
  _ = try JQ.process(filter: "[", input: "{}")
} catch let e as JQError {
  // Detailed error message from jq
  print(e)
} catch {
  print("Unexpected: \(error)")
}
```

## Topics

- ``JQ/JQ``
- ``JQ/JQError``
