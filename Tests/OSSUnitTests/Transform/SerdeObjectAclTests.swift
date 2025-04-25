
@testable import AlibabaCloudOSS
import XCTest

class SerdeObjectAclTests: XCTestCase {
    func testSerializePutObjectAcl() throws {
        var input = OperationInput()
        let acl = "private"
        let versionId = "versionId"

        var request = PutObjectAclRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializePutObjectAcl])
        XCTAssertNil(input.headers["x-oss-object-acl"])

        request = PutObjectAclRequest(objectAcl: acl)
        request.versionId = versionId
        try Serde.serializeInput(&request, &input, [Serde.serializePutObjectAcl])
        XCTAssertEqual(input.headers["x-oss-object-acl"], acl)
        XCTAssertEqual(input.parameters["versionId"], versionId)
    }

    func testDeserializeGetObjectAcl() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetObjectAclResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectAcl]))

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = GetObjectAclResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectAcl]))

        // normal
        let ownerId = "1234513715092****"
        let ownerDisplayName = "1234513715092****"
        let grant = "public-read"

        var bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<AccessControlPolicy>")
        bodyString.append("<Owner>")
        bodyString.append("<ID>\(ownerId)</ID>")
        bodyString.append("<DisplayName>\(ownerDisplayName)</DisplayName>")
        bodyString.append("</Owner>")
        bodyString.append("<AccessControlList>")
        bodyString.append("<Grant>\(grant)</Grant>")
        bodyString.append("</AccessControlList>")
        bodyString.append("</AccessControlPolicy>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = GetObjectAclResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectAcl]))
        XCTAssertEqual(ownerId, result.accessControlPolicy?.owner?.id)
        XCTAssertEqual(ownerDisplayName, result.accessControlPolicy?.owner?.displayName)
        XCTAssertEqual(grant, result.accessControlPolicy?.accessControlList?.grant)
    }
}
