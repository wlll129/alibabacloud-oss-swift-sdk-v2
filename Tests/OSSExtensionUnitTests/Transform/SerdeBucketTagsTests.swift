import AlibabaCloudOSS
@testable import AlibabaCloudOSSExtension
import XCTest

class SerdeBucketTagsTests: XCTestCase {
    func testSerializePutBucketTags() throws {
        var input = OperationInput()

        var xml = "<Tagging />"
        var request = PutBucketTagsRequest(tagging: Tagging())
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializePutBucketTags]))
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))

        xml =
            """
            <Tagging>\
            <TagSet>\
            <Tag>\
            <Key>key1</Key>\
            <Value>value1</Value>\
            </Tag>\
            <Tag>\
            <Key>key2</Key>\
            <Value>value2</Value>\
            </Tag>\
            </TagSet>\
            </Tagging>
            """
        let tags = [Tag(key: "key1", value: "value1"),
                    Tag(key: "key2", value: "value2")]
        request = PutBucketTagsRequest(tagging: Tagging(tagSet: TagSet(tags: tags)))
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializePutBucketTags]))
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))
    }

    func testDeserializeGetBucketTags() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetBucketTagsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketTags]))

        // normal
        let xml =
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <Tagging>\
            <TagSet>\
            <Tag>\
            <Key>key1</Key>\
            <Value>value1</Value>\
            </Tag>\
            <Tag>\
            <Key>key2</Key>\
            <Value>value2</Value>\
            </Tag>\
            </TagSet>\
            </Tagging>
            """
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetBucketTagsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketTags]))
        XCTAssertEqual(result.tagging?.tagSet?.tags?.count, 2)
        XCTAssertEqual(result.tagging?.tagSet?.tags?.first?.key, "key1")
        XCTAssertEqual(result.tagging?.tagSet?.tags?.first?.value, "value1")
        XCTAssertEqual(result.tagging?.tagSet?.tags?.last?.key, "key2")
        XCTAssertEqual(result.tagging?.tagSet?.tags?.last?.value, "value2")
    }
}
