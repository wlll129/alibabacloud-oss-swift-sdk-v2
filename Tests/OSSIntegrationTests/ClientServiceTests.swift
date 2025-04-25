
import AlibabaCloudOSS
import XCTest

class ClientServiceTests: BaseTestCase {
    override func setUp() async throws {
        try await super.setUp()
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }

    func testListBucketsSuccess() async throws {
        // default
        let client = getDefaultClient()
        let bucket = randomBucketName()

        try await createBucket(client: client, bucket: bucket)

        var request = ListBucketsRequest()
        request.prefix = bucket
        var result = try await client.listBuckets(request)
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertNil(result.isTruncated)
        XCTAssertNil(result.maxKeys)
        XCTAssertNil(result.marker)
        XCTAssertNil(result.nextMarker)
        XCTAssertNil(result.prefix)
        XCTAssertNotNil(result.owner?.displayName)
        XCTAssertNotNil(result.owner?.id)
        XCTAssertEqual(result.buckets?.count, 1)
        for content in result.buckets! {
            XCTAssertEqual(content.name, bucket)
            XCTAssertNotNil(content.creationDate)
            XCTAssertTrue(content.extranetEndpoint!.hasSuffix(".aliyuncs.com"))
            XCTAssertTrue(content.intranetEndpoint!.hasSuffix("-internal.aliyuncs.com"))
            XCTAssertNotNil(content.location)
            XCTAssertNotNil(content.region)
            XCTAssertEqual(content.storageClass, "Standard")
        }
        try await cleanBucket(client: client, bucket: bucket)

        // multipart list & set prefix/maxKeys/fetchOwner
        var buckets: [String] = []
        for i in 0 ..< 20 {
            let bucketName = bucket + "-\(i)"
            let putBucketRequest = PutBucketRequest(bucket: bucketName)
            try await assertNoThrow(await client.putBucket(putBucketRequest))
            buckets.append(bucketName)
        }

        var marker: String? = nil
        var isTruncated = true
        var listBuckets: [String] = []
        repeat {
            var request = ListBucketsRequest()
            request.prefix = bucket + "-"
            request.maxKeys = 10
            request.marker = marker
            result = try await client.listBuckets(request)
            XCTAssertEqual(result.statusCode, 200)
            if 20 - listBuckets.count > 10 {
                XCTAssertTrue(result.isTruncated!)
                XCTAssertEqual(result.maxKeys, request.maxKeys)
                XCTAssertEqual(result.marker, request.marker)
                XCTAssertNotNil(result.nextMarker)
                XCTAssertEqual(result.prefix, request.prefix)
            } else {
                XCTAssertNil(result.isTruncated)
                XCTAssertNil(result.maxKeys)
                XCTAssertNil(result.marker)
                XCTAssertNil(result.nextMarker)
                XCTAssertNil(result.prefix)
            }
            XCTAssertEqual(result.buckets?.count, 10)
            for content in result.buckets! {
                listBuckets.append(content.name!)
                XCTAssertNotNil(content.creationDate)
                XCTAssertTrue(content.extranetEndpoint!.hasSuffix(".aliyuncs.com"))
                XCTAssertTrue(content.intranetEndpoint!.hasSuffix("-internal.aliyuncs.com"))
                XCTAssertNotNil(content.location)
                XCTAssertNotNil(content.region)
                XCTAssertEqual(content.storageClass, "Standard")
            }
            isTruncated = result.isTruncated ?? false
            marker = result.nextMarker
        } while isTruncated

        for bucket in buckets {
            XCTAssertTrue(listBuckets.contains(bucket))
        }
    }

    func testListBucketsFail() async throws {
        // default
        let credentialsProvider = AnonymousCredentialsProvider()
        let config = Configuration.default()
        config.withCredentialsProvider(credentialsProvider)
        config.withEndpoint(endpoint)
        config.withRegion(region)

        let client = Client(config)

        let request = ListBucketsRequest()
        try await assertThrowsAsyncError(await client.listBuckets(request)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
            XCTAssertEqual(serverError?.code, "AccessDenied")
        }
    }
}
