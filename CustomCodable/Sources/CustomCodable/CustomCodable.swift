import Swift

// MARK: - Public macro declarations

@attached(member, names: named(CodingKeys), arbitrary)
public macro CustomCodable() = #externalMacro(
    module: "CustomCodableMacros",
    type: "CustomCodableMacro"
)

/// Attach to a stored property to override its JSON key.
/// Usage: @CodingKey("some_json_key") let myProp: String
@attached(peer)
public macro CodingKey(_ key: String) = #externalMacro(
    module: "CustomCodableMacros",
    type: "CodingKeyMacro"
)
