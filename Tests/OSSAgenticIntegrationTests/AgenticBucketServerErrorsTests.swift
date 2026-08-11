import AlibabaCloudOSS
import AlibabaCloudOSSAgentic
import XCTest

/// Error propagation with invalid credentials. No fixture is created: every request is
/// expected to be rejected. Create is answered with 403, while Get and List are asserted
/// loosely because the service answers Get with 404 under an invalid AK.
final class AgenticBucketServerErrorsTests: AgenticBaseTestCase {
    override func setUp() async throws {
        try await super.setUp()
        try skipIfAgenticNotConfigured()
    }

    func testInvalidCredentials() async throws {
        let client = getInvalidAkAgenticClient()
        let bucket = randomAgenticBucketName()

        try await assertThrowsAsyncError(await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: bucket))) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
            XCTAssertFalse(serverError?.requestId.isEmpty ?? true)
        }

        try await assertThrowsAsyncError(await client.getAgenticBucket(GetAgenticBucketRequest(bucket: bucket))) {
            let serverError = $0 as? ServerError
            XCTAssertNotNil(serverError, "expected a ServerError, got \($0)")
            XCTAssertNotEqual(serverError?.statusCode, 0)
        }

        try await assertThrowsAsyncError(await client.listAgenticBuckets(ListAgenticBucketsRequest())) {
            let serverError = $0 as? ServerError
            XCTAssertNotNil(serverError, "expected a ServerError, got \($0)")
            XCTAssertNotEqual(serverError?.statusCode, 0)
        }
    }
}
