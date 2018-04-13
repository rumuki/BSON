import Foundation
import BSON
import XCTest

class BSONEncoderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        var temp: Document = [
            "fred": ["a", "b"]
        ]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDictionaryEncodingDecodesCorrectly() throws {
        let dictionary = ["sample": 4.0, "other": 2.0]
        let codedDocument = try BSONEncoder().encode(dictionary)
        let decodedDictionary = try BSONDecoder().decode([String: Double].self, from: codedDocument)
        XCTAssertEqual(decodedDictionary, dictionary)
    }

    private struct Wrapper<T : Codable> : Codable {
        var value: T
    }

    private func validateEncodesAsPrimitive<T : Primitive>(_ value: T) throws -> Bool {
        let wrapped = Wrapper(value: value)
        let encodedDocument = try BSONEncoder().encode(wrapped)
        return encodedDocument["value"] is T
    }

    private func validateEncodedResult<T : Equatable & Codable, R : Primitive & Equatable>(_ value: T, expected: R) throws -> Bool {
        let wrapped = Wrapper(value: value)
        let encodedDocument = try BSONEncoder().encode(wrapped)
        return encodedDocument["value"] as? R == expected
    }

//    func testObjectIdEncodesAsPrimitive() throws {
//        try XCTAssert(validateEncodesAsPrimitive(ObjectId()))
//    }

    func testDateEncodesAsPrimitive() throws {
        try XCTAssert(validateEncodesAsPrimitive(Date()))
    }

//    func testDataEncodesAsBinary() throws {
//        try XCTAssert(validateEncodedResult(Data(), expected: Binary(data: [], withSubtype: .generic)))
//    }

    func testFloatEncodesAsDouble() throws {
        let floatArray: [Float] = [4]
        let codedDocument = try BSONEncoder().encode(floatArray)
        XCTAssertEqual(codedDocument["0"] as? Double, 4)
    }

    @available(OSX 10.12, *)
    func testEncoding() throws {
        struct Cat : Encodable {
            var _id = ObjectId()
            var name = "Fred"
            var sample: Float = 5.0

            #if !os(Linux)
            struct Tail : Encodable {
                var length = Measurement(value: 30, unit: UnitLength.centimeters)
            }
            var tail = Tail()
            #endif

            var otherNames = ["King", "Queen"]
        }
        let cat = Cat()
        let doc = try BSONEncoder().encode(cat)
        XCTAssertEqual(doc["name"] as? String, cat.name)
        XCTAssertEqual(doc["_id"] as? ObjectId, cat._id)
        XCTAssertEqual(doc["sample"] as? Double, Double(cat.sample))
    }
    
}
