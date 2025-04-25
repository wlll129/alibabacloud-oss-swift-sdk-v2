@testable import AlibabaCloudOSS
import XCTest

class SerdeBucketAclTests: XCTestCase {
    func testSerializePutBucketAcl() {
        do {
            var input = OperationInput()
            let acl = "private"

            var request = PutBucketAclRequest()
            try Serde.serializeInput(&request, &input, [Serde.serializePutBucketAcl])
            XCTAssertNil(input.headers["x-oss-acl"])

            request = PutBucketAclRequest(acl: acl)
            try Serde.serializeInput(&request, &input, [Serde.serializePutBucketAcl])
            XCTAssertEqual(input.headers["x-oss-acl"], acl)

        } catch {
            XCTAssertNil(error.localizedDescription)
        }
    }

    func testDeserializeGetBucketAcl() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetBucketAclResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketAcl]))

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = GetBucketAclResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketAcl]))

        // normal
        let acl = "private"
        let ownerId = "0022012****"
        let displayName = "user_example"
        let xml = """
        <AccessControlPolicy>
            <Owner>
                <ID>\(ownerId)</ID>
                <DisplayName>\(displayName)</DisplayName>
            </Owner>
            <AccessControlList>
                <Grant>\(acl)</Grant>
            </AccessControlList>
        </AccessControlPolicy>
        """.trim()

        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetBucketAclResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketAcl]))
        XCTAssertEqual(result.accessControlPolicy?.accessControlList?.grant, acl)
        XCTAssertEqual(result.accessControlPolicy?.owner?.displayName, displayName)
        XCTAssertEqual(result.accessControlPolicy?.owner?.id, ownerId)
    }
}
