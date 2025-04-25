
@testable import AlibabaCloudOSS
import XCTest

class SerdeObjectTaggingTests: XCTestCase {
    func testSerializePutObjectTagging() throws {
        var input = OperationInput()
        var request = PutObjectTaggingRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializePutObjectTagging])
        XCTAssertNil(input.parameters["versionId"] as Any?)
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Tagging><TagSet></TagSet></Tagging>"
        XCTAssertEqual(try input.body?.readData()?.base64EncodedString(), xml.data(using: .utf8)?.base64EncodedString())

        request = PutObjectTaggingRequest()
        request.versionId = "versionId"
        request.tagging = Tagging(tagSet: TagSet(tags: [Tag(key: "key1", value: "value1"),
                                                        Tag(key: "key2", value: "value2")]))
        try Serde.serializeInput(&request, &input, [Serde.serializePutObjectTagging])
        XCTAssertEqual(input.parameters["versionId"], request.versionId)
        xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Tagging><TagSet><Tag><Key>key1</Key><Value>value1</Value></Tag><Tag><Key>key2</Key><Value>value2</Value></Tag></TagSet></Tagging>"
        XCTAssertEqual(try input.body?.readData()?.base64EncodedString(), xml.data(using: .utf8)?.base64EncodedString())
    }

    func testSerializeGetObjectTagging() throws {
        var input = OperationInput()
        var request = GetObjectTaggingRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeGetObjectTagging])
        XCTAssertNil(input.parameters["versionId"] as Any?)

        request = GetObjectTaggingRequest()
        request.versionId = "versionId"
        try Serde.serializeInput(&request, &input, [Serde.serializeGetObjectTagging])
        XCTAssertEqual(input.parameters["versionId"], request.versionId)
    }

    func testDeserializeGetObjectTagging() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetObjectTaggingResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectTagging]))

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = GetObjectTaggingResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectTagging]))

        // normal
        let tags = [Tag(key: "key1", value: "value1"),
                    Tag(key: "key2", value: "value2")]
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<Tagging>")
        xml.append("<TagSet>")
        for tag in tags {
            xml.append("<Tag>")
            xml.append("<Key>\(tag.key!)</Key>")
            xml.append("<Value>\(tag.value!)</Value>")
            xml.append("</Tag>")
        }
        xml.append("</TagSet>")
        xml.append("</Tagging>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetObjectTaggingResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectTagging]))
        XCTAssertEqual(result.tagging?.tagSet?.tags?.count, tags.count)
        for tag in tags {
            for resultTag in result.tagging!.tagSet!.tags! {
                if tag.key == resultTag.key {
                    XCTAssertEqual(tag.value, resultTag.value)
                }
            }
        }
    }

    func testSerializeDeleteObjectTagging() throws {
        var input = OperationInput()
        var request = DeleteObjectTaggingRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeDeleteObjectTagging])
        XCTAssertNil(input.parameters["versionId"] as Any?)

        request = DeleteObjectTaggingRequest()
        request.versionId = "versionId"
        try Serde.serializeInput(&request, &input, [Serde.serializeDeleteObjectTagging])
        XCTAssertEqual(input.parameters["versionId"], request.versionId)
    }
}
