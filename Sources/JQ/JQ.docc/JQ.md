# ``JQ``

Swift wrapper around the jq JSON processor.

Use the static helpers on ``JQ/JQ`` to evaluate jq filters against JSON text, `Data`, or Codable values.

## Overview

```swift
import JQ

let json = "{" + "\"name\":\"Alice\",\"age\":30" + "}"
let results = try JQ.process(filter: ".name", input: json)
// results == ["\"Alice\""]
```

## Topics

- ``JQ/JQ``
- ``JQ/JQError``

