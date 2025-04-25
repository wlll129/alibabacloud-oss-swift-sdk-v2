import AlibabaCloudOSS
import AlibabaCloudOSSExtension
import XCTest

final class ClientBucketTagsTests: BaseTestCase {
    override func setUp() async throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try await super.setUp()
        bucketName = randomBucketName()
        client = getDefaultClient()

        try await createBucket(client: client!, bucket: bucketName)
    }

    override func tearDown() async throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try await cleanBucket(client: getDefaultClient(), bucket: bucketName)
        try await super.tearDown()
    }

    func testPutAndGetBucketTagsSuccess() async throws {
        var getBucketTagsRequest = GetBucketTagsRequest(bucket: bucketName)
        var getBucketTagsResult = try await client?.getBucketTags(getBucketTagsRequest)
        XCTAssertNil(getBucketTagsResult?.tagging?.tagSet?.tags)

        let tags = [Tag(key: "key1", value: "value1"),
                    Tag(key: "key2", value: "value2")]
        let putBucketTagsRequest = PutBucketTagsRequest(bucket: bucketName,
                                                        tagging: Tagging(tagSet: TagSet(tags: tags)))
        try await assertNoThrow(await client?.putBucketTags(putBucketTagsRequest))

        getBucketTagsRequest = GetBucketTagsRequest(bucket: bucketName)
        getBucketTagsResult = try await client?.getBucketTags(getBucketTagsRequest)
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.count, 2)
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.first?.key, "key1")
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.first?.value, "value1")
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.last?.key, "key2")
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.last?.value, "value2")
    }

    func testPutBucketTagsFail() async {
        var putBucketTagsRequest = PutBucketTagsRequest()
        try await assertThrowsAsyncError(await client?.putBucketTags(putBucketTagsRequest)) {
            let clientError = $0 as? ClientError
            XCTAssertEqual(clientError?.message, "Missing required field, request.bucket.")
        }

        putBucketTagsRequest = PutBucketTagsRequest(bucket: bucketName)
        try await assertThrowsAsyncError(await client?.putBucketTags(putBucketTagsRequest)) {
            let clientError = $0 as? ClientError
            XCTAssertEqual(clientError?.message, "Missing required field, request.tagging.")
        }

        putBucketTagsRequest = PutBucketTagsRequest(bucket: bucketName, tagging: Tagging(tagSet: TagSet()))
        try await assertThrowsAsyncError(await client?.putBucketTags(putBucketTagsRequest)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 400)
            XCTAssertEqual(serverError?.code, "MalformedXML")
        }
    }

    func testGetBucketTagsFail() async {
        let bucket = randomBucketName()
        var request = GetBucketTagsRequest()
        try await assertThrowsAsyncError(await client?.getBucketTags(request)) {
            let clientError = $0 as? ClientError
            XCTAssertEqual(clientError?.message, "Missing required field, request.bucket.")
        }

        request = GetBucketTagsRequest(bucket: bucket)
        try await assertThrowsAsyncError(await client?.getBucketTags(request)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 404)
        }
    }

    func testDeleteBucketTagsSuccess() async throws {
        let tags = [Tag(key: "key1", value: "value1"),
                    Tag(key: "key2", value: "value2")]
        let putBucketTagsRequest = PutBucketTagsRequest(bucket: bucketName,
                                                        tagging: Tagging(tagSet: TagSet(tags: tags)))
        try await assertNoThrow(await client?.putBucketTags(putBucketTagsRequest))

        var getBucketTagsRequest = GetBucketTagsRequest(bucket: bucketName)
        var getBucketTagsResult = try await client?.getBucketTags(getBucketTagsRequest)
        XCTAssertEqual(getBucketTagsResult?.tagging?.tagSet?.tags?.count, 2)

        let request = DeleteBucketTagsRequest(bucket: bucketName)
        try await assertNoThrow(await client?.deleteBucketTags(request))

        getBucketTagsRequest = GetBucketTagsRequest(bucket: bucketName)
        getBucketTagsResult = try await client?.getBucketTags(getBucketTagsRequest)
        XCTAssertNil(getBucketTagsResult?.tagging?.tagSet?.tags)
    }

    func testDeleteBucketTagsFail() async {
        let bucket = randomBucketName()
        var request = DeleteBucketTagsRequest()
        try await assertThrowsAsyncError(await client?.deleteBucketTags(request)) {
            let clientError = $0 as? ClientError
            XCTAssertEqual(clientError?.message, "Missing required field, request.bucket.")
        }

        request = DeleteBucketTagsRequest(bucket: bucket)
        try await assertThrowsAsyncError(await client?.deleteBucketTags(request)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 404)
        }
    }
}
