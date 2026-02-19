# CustomCodable

A Swift macro package that simplifies `Codable` conformance with custom JSON key mapping using property wrappers.

[![Swift Version](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://developer.apple.com/swift/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

## Overview

CustomCodable eliminates the boilerplate of manually writing `CodingKeys` enums and custom `init(from:)` / `encode(to:)` implementations. Simply annotate your struct with `@CustomCodable` and use `@CodingKey("...")` on properties that need custom JSON keys.

## Features

- ✅ **Zero runtime overhead** — pure compile-time code generation
- ✅ **Clean syntax** — decorator-style property attributes
- ✅ **Type-safe** — leverages Swift's type system
- ✅ **Flexible** — mix custom and default keys in the same struct
- ✅ **No dependencies** — uses only Apple's `swift-syntax`

## Requirements

- Swift 6.0+
- Xcode 16.0+
- macOS 10.15+ / iOS 13+ / tvOS 13+ / watchOS 6+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/CustomCodable.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and enter the repository URL.

## Usage

### Basic Example

```swift
import CustomCodable

@CustomCodable
struct User: Codable {
    @CodingKey("user_id") let userId: String
    @CodingKey("full_name") let fullName: String
    let email: String  // Uses "email" as the JSON key (no annotation needed)
}
```

**JSON mapping:**
```json
{
    "user_id": "abc123",
    "full_name": "John Doe",
    "email": "john@example.com"
}
```

### Mixed Key Styles

```swift
@CustomCodable
struct Product: Codable {
    @CodingKey("ProductID") let productId: String
    @CodingKey("ProductName") let productName: String
    let price: Double           // Swift property name = JSON key
    let inStock: Bool           // Swift property name = JSON key
}
```

### What Gets Generated

For this struct:

```swift
@CustomCodable
struct MyStruct: Codable {
    @CodingKey("AUsernAme") let aUserName: String
    let creditScore: Int
}
```

The macro expands to:

```swift
struct MyStruct: Codable {
    let aUserName: String
    let creditScore: Int
    
    enum CodingKeys: String, CodingKey {
        case aUserName = "AUsernAme"
        case creditScore
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aUserName = try container.decode(String.self, forKey: .aUserName)
        creditScore = try container.decode(Int.self, forKey: .creditScore)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aUserName, forKey: .aUserName)
        try container.encode(creditScore, forKey: .creditScore)
    }
}
```

## How It Works

1. **`@CustomCodable`** — Member macro that generates:
   - `CodingKeys` enum with custom/default mappings
   - `init(from:)` decoder
   - `encode(to:)` encoder

2. **`@CodingKey("key")`** — Peer macro (marker attribute) that tells `@CustomCodable` to use a custom JSON key for that property

## Running the Example

The package includes a client executable demonstrating usage:

```bash
cd CustomCodable
swift run CustomCodableClient
```

## Testing

Run the test suite:

```bash
swift test
```

Tests verify:
- ✅ Decoding from JSON with custom keys
- ✅ Encoding to JSON with custom keys
- ✅ Round-trip encoding/decoding
- ✅ Mixed custom and default keys

## Limitations

- Properties must have explicit type annotations (e.g., `let name: String`, not `let name = "default"`)
- Computed properties are automatically excluded
- Works with `struct` and `class` types that conform to `Codable`

## Troubleshooting

### "External macro implementation type not found"

**Cause:** Xcode hasn't trusted the macro plugin yet.

**Fix:** Clean build folder (⇧⌘K), rebuild, and click **"Trust & Enable"** when Xcode prompts.

### "Type 'Target' has no member 'macro'"

**Cause:** Swift version mismatch or incorrect `swift-tools-version`.

**Fix:**
- Ensure you're using **Xcode 16+** (Swift 6.0+)
- Check `xcode-select -p` points to the correct Xcode
- Verify first line of `Package.swift` is `// swift-tools-version: 6.1`

### Build fails with swift-syntax errors

**Cause:** swift-syntax version mismatch with Swift compiler.

**Fix:** Ensure swift-syntax version matches your Swift version:
- Swift 6.0 → `600.0.1`
- Swift 6.1 → `601.x.x`
- Swift 6.2 → `602.0.0-prerelease-...`

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built with Apple's [swift-syntax](https://github.com/swiftlang/swift-syntax) macro system.

## See Also

- [Swift Macros Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
- [swift-syntax Repository](https://github.com/swiftlang/swift-syntax)
- [WWDC23: Write Swift Macros](https://developer.apple.com/videos/play/wwdc2023/10166/)
