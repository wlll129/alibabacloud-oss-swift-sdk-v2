@testable import AlibabaCloudOSS
@testable import AlibabaCloudOSSAgentic
import XCTest

final class AgenticBucketClientTests: XCTestCase {
    private let accountId = "137"
    private let region = "cn-hangzhou"

    private func makeConfig(accountId: String? = "137") -> Configuration {
        let config = Configuration.default()
            .withRegion(region)
            .withCredentialsProvider(StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk"))
            .withRetryer(NopRetryer())
        if let accountId = accountId {
            config.withAccountId(accountId)
        }
        return config
    }

    private func makeClient(_ mock: AgenticMock, accountId: String? = "137") -> AgenticBucketClient {
        return AgenticBucketClient(makeConfig(accountId: accountId)) { $0.executeMW = mock }
    }

    private func makeBucketSpaceClient(_ mock: AgenticMock, accountId: String? = "137") -> Client {
        return BucketSpaceClient.make(makeConfig(accountId: accountId)) { $0.executeMW = mock }
    }

    // MARK: - Host routing

    func testCreateAgenticBucketHost() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        _ = try? await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: "prefix"))
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
        XCTAssertEqual(mock.requests[0].method, "PUT")
    }

    func testGetAgenticBucketHostAndQuery() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        _ = try? await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix"))
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
        XCTAssertEqual(mock.requests[0].method, "GET")
    }

    func testListAgenticBucketsUsesRegionalHost() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        _ = try? await client.listAgenticBuckets(ListAgenticBucketsRequest())
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        // No bucket -> regional host, no suffix injected.
        XCTAssertTrue(uri.hasPrefix("https://oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertFalse(uri.contains("ab-apsr"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
    }

    func testPutAgenticBucketStatusQuery() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        var request = PutAgenticBucketStatusRequest(bucket: "prefix")
        request.status = "Disabled"
        _ = try? await client.putAgenticBucketStatus(request)
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
        XCTAssertTrue(uri.contains("status"), uri)
        XCTAssertEqual(mock.requests[0].method, "PUT")
    }

    func testListBucketSpacesQuery() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        _ = try? await client.listBucketSpaces(ListBucketSpacesRequest(bucket: "prefix"))
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
        XCTAssertTrue(uri.contains("bucketSpace"), uri)
    }

    func testInvokeOperationRewritesHost() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        let input = OperationInput(
            operationName: "GetAgenticBucket",
            method: "GET",
            headers: ["Content-Type": "application/xml"],
            parameters: ["agenticBucket": ""],
            bucket: "prefix"
        )
        _ = try? await client.invokeOperation(input)
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
        XCTAssertTrue(uri.contains("agenticBucket"), uri)
    }

    // MARK: - Scoped BucketSpace client

    func testBucketSpaceScopedClientHost() async throws {
        let mock = AgenticMock()
        let scoped = makeBucketSpaceClient(mock)
        _ = try? await scoped.putObject(PutObjectRequest(bucket: "prefix", key: "obj"))
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-bs-apsr.oss-cn-hangzhou.aliyuncs.com/obj"), uri)
    }

    func testBucketSpaceInvokeOperationRewritesHost() async throws {
        let mock = AgenticMock()
        let scoped = makeBucketSpaceClient(mock)
        let input = OperationInput(
            operationName: "GetObject",
            method: "GET",
            bucket: "prefix",
            key: "obj"
        )
        _ = try? await scoped.invokeOperation(input)
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-bs-apsr.oss-cn-hangzhou.aliyuncs.com/obj"), uri)
    }

    // MARK: - Required-field errors

    func testCreateAgenticBucketRequiresBucket() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        await XCTAssertThrowsErrorAsync(try await client.createAgenticBucket(CreateAgenticBucketRequest()))
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testListBucketSpacesRequiresBucket() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        await XCTAssertThrowsErrorAsync(try await client.listBucketSpaces(ListBucketSpacesRequest()))
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testPutAgenticBucketStatusRequiresStatus() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        await XCTAssertThrowsErrorAsync(try await client.putAgenticBucketStatus(PutAgenticBucketStatusRequest(bucket: "prefix")))
        XCTAssertEqual(mock.requests.count, 0)
    }

    // MARK: - Lazy account-id validation

    func testInvalidAccountIdConstructsButFailsOnFirstOp() async throws {
        let mock = AgenticMock()
        // Non-digit account id: construction must succeed.
        let client = makeClient(mock, accountId: "abc")
        var thrown: Error?
        do {
            _ = try await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix"))
        } catch {
            thrown = error
        }
        XCTAssertNotNil(thrown)
        if let clientError = thrown as? ClientError {
            XCTAssertEqual(clientError.code, "ValidationError")
        } else {
            XCTFail("expected ClientError, got \(String(describing: thrown))")
        }
        // Deferred error is thrown before any request is sent.
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testEmptyAccountIdIsAllowed() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock, accountId: "")
        _ = try? await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix"))
        // Empty account id does not raise the validation error; the request is sent.
        XCTAssertEqual(mock.requests.count, 1)
    }

    func testMissingAccountIdIsNotBlocked() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock, accountId: nil)
        _ = try? await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix"))
        // nil account id -> empty segment in the physical name, request still sent.
        XCTAssertEqual(mock.requests.count, 1)
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.contains("prefix--cn-hangzhou-ab-apsr"), uri)
    }

    // MARK: - Success responses

    func testCreateAgenticBucketSuccess() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        let result = try await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: "prefix"))
        XCTAssertEqual(result.commonProp.statusCode, 200)
        XCTAssertEqual(mock.requests.count, 1)
        XCTAssertEqual(mock.requests[0].method, "PUT")
    }

    func testDeleteAgenticBucketSuccessAndHost() async throws {
        let mock = AgenticMock()
        mock.responses = [AgenticMock.response(204)]
        let client = makeClient(mock)
        let result = try await client.deleteAgenticBucket(DeleteAgenticBucketRequest(bucket: "prefix"))
        XCTAssertEqual(result.commonProp.statusCode, 204)
        XCTAssertEqual(mock.requests.count, 1)
        XCTAssertEqual(mock.requests[0].method, "DELETE")
        let uri = mock.requests[0].requestUri.absoluteString
        XCTAssertTrue(uri.hasPrefix("https://prefix-137-cn-hangzhou-ab-apsr.oss-cn-hangzhou.aliyuncs.com/"), uri)
    }

    func testGetAgenticBucketParsesResponse() async throws {
        let mock = AgenticMock()
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<AgenticBucketInfo>")
        xml.append("<Name>prefix-137-cn-hangzhou-ab-apsr</Name>")
        xml.append("<Owner>137</Owner>")
        xml.append("<Region>cn-hangzhou</Region>")
        xml.append("<Status>Enabled</Status>")
        xml.append("</AgenticBucketInfo>")
        mock.responses = [AgenticMock.response(200, xml)]
        let client = makeClient(mock)
        let result = try await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix"))
        XCTAssertEqual(result.agenticBucketInfo?.name, "prefix-137-cn-hangzhou-ab-apsr")
        XCTAssertEqual(result.agenticBucketInfo?.owner, "137")
        XCTAssertEqual(result.agenticBucketInfo?.region, "cn-hangzhou")
        XCTAssertEqual(result.agenticBucketInfo?.status, "Enabled")
    }

    func testListAgenticBucketsParsesResponse() async throws {
        let mock = AgenticMock()
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<ListAgenticBucketsResult>")
        xml.append("<Region>cn-hangzhou</Region><Owner>137</Owner><IsTruncated>false</IsTruncated>")
        xml.append("<AgenticBuckets><AgenticBucket><Name>a</Name></AgenticBucket></AgenticBuckets>")
        xml.append("</ListAgenticBucketsResult>")
        mock.responses = [AgenticMock.response(200, xml)]
        let client = makeClient(mock)
        let result = try await client.listAgenticBuckets(ListAgenticBucketsRequest())
        XCTAssertEqual(result.region, "cn-hangzhou")
        XCTAssertEqual(result.owner, "137")
        XCTAssertEqual(result.isTruncated, false)
        XCTAssertEqual(result.agenticBuckets?.count, 1)
        XCTAssertEqual(result.agenticBuckets?[0].name, "a")
    }

    func testListBucketSpacesParsesResponse() async throws {
        let mock = AgenticMock()
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<ListBucketSpacesResult>")
        xml.append("<Owner><ID>137</ID><DisplayName>acct</DisplayName></Owner>")
        xml.append("<IsTruncated>false</IsTruncated>")
        xml.append("<BucketSpaces><BucketSpace><Name>s1</Name></BucketSpace></BucketSpaces>")
        xml.append("</ListBucketSpacesResult>")
        mock.responses = [AgenticMock.response(200, xml)]
        let client = makeClient(mock)
        let result = try await client.listBucketSpaces(ListBucketSpacesRequest(bucket: "prefix"))
        XCTAssertEqual(result.owner?.id, "137")
        XCTAssertEqual(result.owner?.displayName, "acct")
        XCTAssertEqual(result.isTruncated, false)
        XCTAssertEqual(result.bucketSpaces?.count, 1)
        XCTAssertEqual(result.bucketSpaces?[0].name, "s1")
    }

    // MARK: - Error responses

    func testCreateAgenticBucketErrorResponse() async throws {
        let mock = AgenticMock()
        mock.responses = [AgenticMock.error(403, code: "InvalidAccessKeyId")]
        let client = makeClient(mock)
        let error = await captureError(try await client.createAgenticBucket(CreateAgenticBucketRequest(bucket: "prefix")))
        let serverError = error as? ServerError
        XCTAssertEqual(serverError?.statusCode, 403)
        XCTAssertEqual(serverError?.code, "InvalidAccessKeyId")
    }

    func testGetAgenticBucketErrorResponse() async throws {
        let mock = AgenticMock()
        mock.responses = [AgenticMock.error(404, code: "NoSuchAgenticBucket")]
        let client = makeClient(mock)
        let error = await captureError(try await client.getAgenticBucket(GetAgenticBucketRequest(bucket: "prefix")))
        let serverError = error as? ServerError
        XCTAssertEqual(serverError?.statusCode, 404)
        XCTAssertEqual(serverError?.code, "NoSuchAgenticBucket")
    }

    func testListAgenticBucketsErrorResponse() async throws {
        let mock = AgenticMock()
        mock.responses = [AgenticMock.error(403, code: "AccessDenied")]
        let client = makeClient(mock)
        let error = await captureError(try await client.listAgenticBuckets(ListAgenticBucketsRequest()))
        XCTAssertEqual((error as? ServerError)?.code, "AccessDenied")
    }

    func testListBucketSpacesErrorResponse() async throws {
        let mock = AgenticMock()
        mock.responses = [AgenticMock.error(404, code: "NoSuchAgenticBucket")]
        let client = makeClient(mock)
        let error = await captureError(try await client.listBucketSpaces(ListBucketSpacesRequest(bucket: "prefix")))
        XCTAssertEqual((error as? ServerError)?.statusCode, 404)
    }

    // MARK: - Additional required-field errors

    func testDeleteAgenticBucketRequiresBucket() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        await XCTAssertThrowsErrorAsync(try await client.deleteAgenticBucket(DeleteAgenticBucketRequest()))
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testGetAgenticBucketRequiresBucket() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        await XCTAssertThrowsErrorAsync(try await client.getAgenticBucket(GetAgenticBucketRequest()))
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testPutAgenticBucketStatusRequiresBucket() async throws {
        let mock = AgenticMock()
        let client = makeClient(mock)
        var request = PutAgenticBucketStatusRequest()
        request.status = "Enabled"
        await XCTAssertThrowsErrorAsync(try await client.putAgenticBucketStatus(request))
        XCTAssertEqual(mock.requests.count, 0)
    }

    func testBucketSpaceScopedClientInvalidAccountIdDeferred() async throws {
        let mock = AgenticMock()
        let scoped = makeBucketSpaceClient(mock, accountId: "abc")
        let error = await captureError(try await scoped.putObject(PutObjectRequest(bucket: "prefix", key: "obj")))
        XCTAssertEqual((error as? ClientError)?.code, "ValidationError")
        // Deferred error is thrown before any request is sent.
        XCTAssertEqual(mock.requests.count, 0)
    }
}

private func XCTAssertThrowsErrorAsync(
    _ expression: @autoclosure () async throws -> some Any,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error to be thrown", file: file, line: line)
    } catch {
        // expected
    }
}

private func captureError(
    _ expression: @autoclosure () async throws -> some Any
) async -> Error? {
    do {
        _ = try await expression()
        return nil
    } catch {
        return error
    }
}

private final class AgenticMock: ExecuteMiddleware {
    var requests: [RequestMessage] = []
    var responses: [ResponseMessage] = []

    func execute(request: RequestMessage, context _: ExecuteContext) async throws -> ResponseMessage {
        requests.append(request)
        if responses.isEmpty {
            return AgenticMock.ok()
        }
        return responses.removeFirst()
    }

    static func ok(_ body: String = "") -> ResponseMessage {
        return response(200, body)
    }

    static func response(_ statusCode: Int, _ body: String = "") -> ResponseMessage {
        let data = body.data(using: .utf8)!
        return ResponseMessage(
            statusCode: statusCode,
            headers: [
                "x-oss-request-id": "req-id",
                "Content-Type": "application/xml",
                "Content-Length": String(data.count),
            ],
            content: ByteStream.data(data),
            request: nil
        )
    }

    static func error(_ statusCode: Int, code: String) -> ResponseMessage {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <Error><Code>\(code)</Code><Message>msg</Message><RequestId>req-id</RequestId></Error>
        """
        return response(statusCode, xml)
    }
}
