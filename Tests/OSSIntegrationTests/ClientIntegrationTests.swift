import AlibabaCloudOSS
import XCTest

final class ClientIntegrationTests: BaseTestCase {
    func testInvokeOperationWithPutSuccess() async throws {
        // default
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()
        let content = "hello world".data(using: .utf8)!

        try await createBucket(client: client, bucket: bucket)

        var operationInput = OperationInput(method: "PUT")
        operationInput.bucket = bucket
        operationInput.key = key
        operationInput.body = .data(content)

        if operationInput.headers[Headers.contentType.rawValue] == nil {
            switch operationInput.body {
            case let .file(url):
                operationInput.headers[Headers.contentType.rawValue] = MimeUtils.getMimeType(fileURL: url)
            default:
                operationInput.headers[Headers.contentType.rawValue] = "application/octet-stream"
            }
        }

        try await assertNoThrow(await client.invokeOperation(operationInput))

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testInvokeOperationWithPutFail() async throws {
        // default
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()
        let content = "hello world".data(using: .utf8)!

        var operationInput = OperationInput(method: "PUT")
        operationInput.bucket = bucket
        operationInput.key = key
        operationInput.body = .data(content)

        if operationInput.headers[Headers.contentType.rawValue] == nil {
            switch operationInput.body {
            case let .file(url):
                operationInput.headers[Headers.contentType.rawValue] = MimeUtils.getMimeType(fileURL: url)
            default:
                operationInput.headers[Headers.contentType.rawValue] = "application/octet-stream"
            }
        }

        try await assertThrowsAsyncError(await client.invokeOperation(operationInput)) { error in
            let serverError = error as! ServerError
            XCTAssertEqual(serverError.statusCode, 404)
            XCTAssertEqual(serverError.code, "NoSuchBucket")
            XCTAssertEqual(serverError.message, "The specified bucket does not exist.")
            XCTAssertEqual(serverError.ec, "0015-00000101")
            XCTAssertNotNil(serverError.requestId)
        }
    }

    func testInvokeOperationWithGetSuccess() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()
        let content = "hello world".data(using: .utf8)!

        try await createBucket(client: client, bucket: bucket)

        let putRequest = PutObjectRequest(bucket: bucket,
                                          key: key,
                                          body: .data(content))
        try await assertNoThrow(await client.putObject(putRequest))

        var operationInput = OperationInput(method: "GET")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertNoThrow(await client.invokeOperation(operationInput))

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testInvokeOperationWithGetFail() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()

        try await createBucket(client: client, bucket: bucket)

        var operationInput = OperationInput(method: "GET")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertThrowsAsyncError(await client.invokeOperation(operationInput)) { error in
            let serverError = error as! ServerError
            XCTAssertEqual(serverError.statusCode, 404)
            XCTAssertEqual(serverError.code, "NoSuchKey")
            XCTAssertEqual(serverError.message, "The specified key does not exist.")
            XCTAssertEqual(serverError.ec, "0026-00000001")
            XCTAssertNotNil(serverError.requestId)
        }

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testInvokeOperationWithDeleteSuccess() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()
        let content = "hello world".data(using: .utf8)!

        try await createBucket(client: client, bucket: bucket)

        let putRequest = PutObjectRequest(bucket: bucket,
                                          key: key,
                                          body: .data(content))
        try await assertNoThrow(await client.putObject(putRequest))

        var operationInput = OperationInput(method: "DELETE")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertNoThrow(await client.invokeOperation(operationInput))

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testInvokeOperationWithDeleteFail() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()

        var operationInput = OperationInput(method: "DELETE")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertThrowsAsyncError(await client.invokeOperation(operationInput)) { error in
            let serverError = error as! ServerError
            XCTAssertEqual(serverError.statusCode, 404)
            XCTAssertEqual(serverError.code, "NoSuchBucket")
            XCTAssertEqual(serverError.message, "The specified bucket does not exist.")
            XCTAssertEqual(serverError.ec, "0015-00000101")
            XCTAssertNotNil(serverError.requestId)
        }
    }

    func testInvokeOperationWithHeadSuccess() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()
        let content = "hello world".data(using: .utf8)!

        try await createBucket(client: client, bucket: bucket)

        let putRequest = PutObjectRequest(bucket: bucket,
                                          key: key,
                                          body: .data(content))
        try await assertNoThrow(await client.putObject(putRequest))

        var operationInput = OperationInput(method: "HEAD")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertNoThrow(await client.invokeOperation(operationInput))

        try await cleanBucket(client: client, bucket: bucket)
    }

    func testInvokeOperationWithHeadFail() async throws {
        let client = getDefaultClient()
        let bucket = randomBucketName()
        let key = randomObjectName()

        var operationInput = OperationInput(method: "HEAD")
        operationInput.bucket = bucket
        operationInput.key = key

        try await assertThrowsAsyncError(await client.invokeOperation(operationInput)) { error in
            let serverError = error as! ServerError
            XCTAssertEqual(serverError.statusCode, 404)
            XCTAssertEqual(serverError.ec, "0015-00000101")
            XCTAssertNotNil(serverError.requestId)
        }
    }
}
