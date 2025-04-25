
@testable import AlibabaCloudOSS
import XCTest

class SerdeObjectSymlinkTests: XCTestCase {
    func testSerializePutSymlink() throws {
        var input = OperationInput()
        var request = PutSymlinkRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializePutSymlink])
        XCTAssertNil(input.headers["x-oss-symlink-target"])
        XCTAssertNil(input.headers["x-oss-object-acl"])
        XCTAssertNil(input.headers["x-oss-storage-class"])
        XCTAssertNil(input.headers["x-oss-forbid-overwrite"])

        request = PutSymlinkRequest()
        request.symlinkTarget = "symlinkTarget"
        request.objectAcl = "private"
        request.storageClass = "Archive"
        request.forbidOverwrite = false
        try Serde.serializeInput(&request, &input, [Serde.serializePutSymlink])
        XCTAssertEqual(input.headers["x-oss-symlink-target"], request.symlinkTarget)
        XCTAssertEqual(input.headers["x-oss-object-acl"], request.objectAcl)
        XCTAssertEqual(input.headers["x-oss-storage-class"], request.storageClass)
        XCTAssertEqual(input.headers["x-oss-forbid-overwrite"], request.forbidOverwrite?.toString())
    }

    func testSerializeGetSymlink() throws {
        var input = OperationInput()
        var request = GetSymlinkRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeGetSymlink])
        XCTAssertNil(input.parameters["versionId"] as Any?)

        request = GetSymlinkRequest()
        request.versionId = "versionId"
        try Serde.serializeInput(&request, &input, [Serde.serializeGetSymlink])
        XCTAssertEqual(input.parameters["versionId"], request.versionId)
    }
}
