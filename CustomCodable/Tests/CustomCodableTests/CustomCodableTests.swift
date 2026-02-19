import XCTest
import CustomCodable

// MARK: - Example usage

@CustomCodable
struct MyStruct: Codable {
    @CodingKey("AUsernAme") let aUserName: String
    let creditScore: Int  // no attribute = uses "creditScore" as the key
}

// MARK: - Tests

final class CustomCodableTests: XCTestCase {

    func testDecoding() throws {
        let json = """
        {
            "AUsernAme": "alice",
            "creditScore": 750
        }
        """.data(using: .utf8)!

        let value = try JSONDecoder().decode(MyStruct.self, from: json)
        XCTAssertEqual(value.aUserName, "alice")
        XCTAssertEqual(value.creditScore, 750)
    }

    func testEncoding() throws {
        let value = MyStruct(aUserName: "bob", creditScore: 800)
        let data = try JSONEncoder().encode(value)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Custom key must be used
        XCTAssertEqual(dict["AUsernAme"] as? String, "bob")
        // Default key must be used
        XCTAssertEqual(dict["creditScore"] as? Int, 800)
        // Swift property name must NOT appear
        XCTAssertNil(dict["aUserName"], "Swift property name must not appear in JSON")
    }

    func testRoundtrip() throws {
        let original = MyStruct(aUserName: "carol", creditScore: 650)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MyStruct.self, from: data)
        XCTAssertEqual(decoded.aUserName, original.aUserName)
        XCTAssertEqual(decoded.creditScore, original.creditScore)
    }
}

