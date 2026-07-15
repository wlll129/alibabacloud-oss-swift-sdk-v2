import AlibabaCloudOSS
import AlibabaCloudOSSAgentic
import XCTest

final class AgenticBucketClientTests: BaseTestCase {
    private func agenticConfig(accessKeyId: String? = nil, accessKeySecret: String? = nil) -> Configuration {
        let credentialsProvider = StaticCredentialsProvider(
            accessKeyId: accessKeyId ?? self.accessKeyId,
            accessKeySecret: accessKeySecret ?? self.accessKeySecret
        )
        let config = Configuration.default()
        config.withCredentialsProvider(credentialsProvider)
        config.withEndpoint(endpoint)
        config.withRegion(region)
        config.withAccountId(userId)
        return config
    }

    private func getAgenticClient() -> AgenticBucketClient {
        return AgenticBucketClient(agenticConfig())
    }

    private func getInvalidAkAgenticClient() -> AgenticBucketClient {
        return AgenticBucketClient(agenticConfig(accessKeyId: "invalid-ak", accessKeySecret: "invalid-sk"))
    }

    // The physical prefix used to name agentic buckets. Kept short and unique so the
    // physical name {prefix}-{accountId}-{region}-ab-apsr stays within OSS length limits.
    private func randomAgenticPrefix() -> String {
        return "agtsdk\(randomStr(6))"
    }

    private func cleanAgenticBucket(_ client: AgenticBucketClient, _ prefix: String) async {
        try? await client.deleteAgenticBucket(DeleteAgenticBucketRequest(bucket: prefix))
    }

    // MARK: - Lifecycle

    func testAgenticBucketLifecycle() async throws {
        let client = getAgenticClient()
        let prefix = randomAgenticPrefix()

        // 1. Create
        let createResult = try await client.createAgenticBucket(
            CreateAgenticBucketRequest(
                bucket: prefix,
                createAgenticBucketConfiguration: CreateAgenticBucketConfiguration(
                    storageClass: "Standard",
                    dataRedundancyType: "LRS"
                )
            )
        )
        XCTAssertEqual(createResult.statusCode, 200)

        defer { Task { await cleanAgenticBucket(client, prefix) } }

        // 2. Get, verify fields
        let getResult = try await client.getAgenticBucket(GetAgenticBucketRequest(bucket: prefix))
        XCTAssertEqual(getResult.statusCode, 200)
        let info = try XCTUnwrap(getResult.agenticBucketInfo)
        XCTAssertTrue(info.name?.contains(prefix) ?? false, info.name ?? "nil")
        XCTAssertEqual(info.region, region)
        XCTAssertEqual(info.storageClass, "Standard")
        XCTAssertEqual(info.dataRedundancyType, "LRS")
        XCTAssertNotNil(info.status)
        XCTAssertNotNil(info.createTime)

        // 3. Status
        let statusResult = try await client.putAgenticBucketStatus(
            PutAgenticBucketStatusRequest(bucket: prefix, status: "Enabled")
        )
        XCTAssertEqual(statusResult.statusCode, 200)

        // 4. List, verify the created bucket appears (via paginator)
        var found = false
        for try await page in client.listAgenticBucketsPaginator(ListAgenticBucketsRequest()) {
            XCTAssertEqual(page.statusCode, 200)
            for summary in page.agenticBuckets ?? [] {
                if summary.name?.contains(prefix) ?? false {
                    found = true
                }
            }
        }
        XCTAssertTrue(found, "created agentic bucket should appear in list")

        // 5. ListBucketSpaces
        let spacesResult = try await client.listBucketSpaces(ListBucketSpacesRequest(bucket: prefix))
        XCTAssertEqual(spacesResult.statusCode, 200)

        // 6. Delete
        let deleteResult = try await client.deleteAgenticBucket(DeleteAgenticBucketRequest(bucket: prefix))
        XCTAssertTrue(deleteResult.statusCode == 200 || deleteResult.statusCode == 204)
    }

    // MARK: - Required-field errors

    func testRequiredFieldErrors() async throws {
        let client = getAgenticClient()

        try await assertThrowsAsyncError(await client.createAgenticBucket(CreateAgenticBucketRequest())) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Missing required field, request.bucket.", clientError?.message)
        }

        try await assertThrowsAsyncError(await client.getAgenticBucket(GetAgenticBucketRequest())) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Missing required field, request.bucket.", clientError?.message)
        }

        try await assertThrowsAsyncError(await client.listBucketSpaces(ListBucketSpacesRequest())) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Missing required field, request.bucket.", clientError?.message)
        }
    }

    // MARK: - Not-exist errors

    func testGetNotExist() async throws {
        let client = getAgenticClient()
        let prefix = randomAgenticPrefix()

        try await assertThrowsAsyncError(await client.getAgenticBucket(GetAgenticBucketRequest(bucket: prefix))) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 404)
            XCTAssertNotNil(serverError?.requestId)
        }
    }

    // MARK: - Invalid credential errors

    func testInvalidCredentials() async throws {
        let client = getInvalidAkAgenticClient()
        let prefix = randomAgenticPrefix()

        try await assertThrowsAsyncError(await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: prefix))) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
            XCTAssertNotNil(serverError?.requestId)
        }

        try await assertThrowsAsyncError(await client.listAgenticBuckets(ListAgenticBucketsRequest())) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 403)
        }
    }

    // MARK: - BucketSpace scoped client

    func testBucketSpaceObjectLifecycle() async throws {
        let client = getAgenticClient()
        let bsClient = BucketSpaceClient.make(agenticConfig())
        let prefix = randomAgenticPrefix()

        let createResult = try await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: prefix))
        XCTAssertEqual(createResult.statusCode, 200)

        defer { Task { await cleanAgenticBucket(client, prefix) } }

        let key = randomObjectName()
        let content = "hello agentic".data(using: .utf8)!

        let putResult = try await bsClient.putObject(
            PutObjectRequest(bucket: prefix, key: key, body: .data(content))
        )
        XCTAssertEqual(putResult.statusCode, 200)

        let getResult = try await bsClient.getObject(GetObjectRequest(bucket: prefix, key: key))
        XCTAssertEqual(getResult.statusCode, 200)

        try await assertNoThrow(await bsClient.deleteObject(DeleteObjectRequest(bucket: prefix, key: key)))
    }
}
