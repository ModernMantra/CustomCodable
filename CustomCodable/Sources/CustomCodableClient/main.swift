import CustomCodable

@CustomCodable
struct MyStruct: Codable {
    @CodingKey("AUsernAme") let aUserName: String
    let creditScore: Int  // no attribute = uses "creditScore" as the key
}
