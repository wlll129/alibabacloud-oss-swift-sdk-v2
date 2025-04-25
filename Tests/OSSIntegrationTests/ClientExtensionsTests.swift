import AlibabaCloudOSS
import XCTest

class ClientExtensionsTests: BaseTestCase {
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func testGetObjectToFile() async throws {
        let bucket = randomBucketName()
        let objectKey = randomObjectName()
        let data = "hello oss".data(using: .utf8)!
        let client = getDefaultClient()

        let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        let file = URL(fileURLWithPath: "\(document!)/file1")
        if FileManager.default.fileExists(atPath: file.absoluteString.replacingOccurrences(of: "file://", with: "")) {
            try FileManager.default.removeItem(at: file)
        }

        try await createBucket(client: client, bucket: bucket)

        let putRequest = PutObjectRequest(bucket: bucket,
                                          key: objectKey,
                                          body: .data(data))
        let putResult = try await client.putObject(putRequest)
        XCTAssertEqual(putResult.statusCode, 200)

        let getRequest = GetObjectRequest(bucket: bucket,
                                          key: objectKey)
        let getResult = try await client.getObjectToFile(getRequest, file)

        XCTAssertEqual(getResult.statusCode, 200)
        let md5 = data.calculateMd5().toBase64String()
        let md = try Data(contentsOf: file).calculateMd5().toBase64String()
        XCTAssertEqual(md, md5)

        try FileManager.default.removeItem(at: file)
        try await cleanBucket(client: client, bucket: bucket)
    }

    func testIsBucketExistSuccess() async throws {
        let bucket = randomBucketName()
        let client = getDefaultClient()

        // doesn't exist
        var isExist = try await client.isBucketExist(bucket)
        XCTAssertFalse(isExist)

        // exist
        try await createBucket(client: client, bucket: bucket)

        isExist = try await client.isBucketExist(bucket)
        XCTAssertTrue(isExist)
        try await cleanBucket(client: client, bucket: bucket)
    }

    func testIsBucketExistFail() async throws {
        let bucket = randomBucketName()
        let credentialsProvider = AnonymousCredentialsProvider()
        let config = Configuration.default()
            .withRegion(region)
            .withCredentialsProvider(credentialsProvider)
        let client = Client(config)
        let defaultClient = getDefaultClient()

        try await createBucket(client: defaultClient, bucket: bucket)

        // client error
        try await assertThrowsAsyncError(await client.isBucketExist("bucket-")) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Bucket name is invalid, got bucket-.", clientError?.message)
        }

        // server error
        try await assertThrowsAsyncError(await client.isBucketExist(bucket)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
        }
        try await cleanBucket(client: defaultClient, bucket: bucket)
    }

    func testIsObjectExistSuccess() async throws {
        let bucket = randomBucketName()
        let key = randomObjectName()
        let client = getDefaultClient()

        try await createBucket(client: getDefaultClient(), bucket: bucket)

        // doesn't exist
        var isExist = try await client.isObjectExist(bucket, key)
        XCTAssertFalse(isExist)

        // exist
        let request = PutObjectRequest(bucket: bucket,
                                       key: key,
                                       body: .data("hello oss".data(using: .utf8)!))
        try await assertNoThrow(await client.putObject(request))
        isExist = try await client.isObjectExist(bucket, key)
        XCTAssertTrue(isExist)

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testIsObjectExistFail() async throws {
        let bucket = randomBucketName()
        let key = randomObjectName()
        let client = getDefaultClient()

        let credentialsProvider = AnonymousCredentialsProvider()
        let config = Configuration.default()
            .withRegion(region)
            .withCredentialsProvider(credentialsProvider)
        let anonymousClient = Client(config)

        try await createBucket(client: getDefaultClient(), bucket: bucket)

        // client error
        try await assertThrowsAsyncError(await client.isObjectExist(bucket, "")) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Object name is invalid, got .", clientError?.message)
        }

        // server error
        try await assertThrowsAsyncError(await anonymousClient.isObjectExist(bucket, key)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
        }
        try await cleanBucket(client: getDefaultClient(), bucket: bucket)
    }
}
