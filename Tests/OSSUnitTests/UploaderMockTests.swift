import XCTest
@testable import AlibabaCloudOSS

class UploaderMockTests: XCTestCase {
    
    func testUploaderSinglePart() async throws {
        let file = Utils.createTestFile("test-file", 1 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            XCTAssertEqual(requestMessage.method, "PUT")
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploads"))
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploadId"))
            return ResponseMessage(
                statusCode: 200,
                headers: ["x-oss-hash-crc64ecma": String(crc)],
            )
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertNil($0.uploadId)
            XCTAssertEqual($0.hashCRC64, crc)
        }
        Utils.removeTestFile(file!)
    }
    
    func testUploaderMultiPartSequential() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        Utils.removeTestFile(file!)
    }
    
    func testUploaderMultiPartParallel() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.parallelNum = 1
        }
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadParallel() async throws {
        let file = Utils.createTestFile("test-file", 4 * 256 * 1024 + 123)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        var times: [Int: Int] = [:]
        let lock = NSLock()
        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    let string = requestMessage.requestUri.absoluteString.components(separatedBy: "partNumber=").last!
                    let index = Int(string[string.startIndex..<string.index(string.startIndex, offsetBy: 1)])
                    if index! <= 4 {
                        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                    }
                    await withCheckedContinuation { continuation in
                        lock.lock()
                        times[index!] = Int(Date().timeIntervalSince1970)
                        lock.unlock()
                        continuation.resume()
                    }
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.partSize = 256 * 1024
            $0.parallelNum = 4
        }
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        
        for i in 1...5 {
            XCTAssertLessThanOrEqual(times[4]!, times[i]!)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadArgmentCheck() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        let client = Client(config)
        let uploader = Uploader(client)
        
        // nil bucket & key & nody
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.bucket.")
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.key.")
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key"
            )
        )) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.body.")
        }
        
        //Invalid filePath
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: "/file/error"))
            )
        )) {
            let error = $0 as? ClientError
            XCTAssertNotNil(error)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadSinglePartFail() async throws {
        let file = Utils.createTestFile("test-file", 1 * 1024 * 1024)
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)
        
        let mock = MockProcessRequest { requestMessage, context in
            XCTAssertEqual(requestMessage.method, "PUT")
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploads"))
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploadId"))
            return ResponseMessage(
                statusCode: 403,
                headers: [:],
            )
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.partSize = 1 * 1024 * 1024
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadInitiateMultipartUploadFail() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)
        
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 403,
                        headers: [:],
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "DELETE":
                return ResponseMessage(
                    statusCode: 206,
                    headers: [:]
                )
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadSequentialUploadPartFail() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)
        
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 403,
                        headers: [:],
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "DELETE":
                return ResponseMessage(
                    statusCode: 206,
                    headers: [:]
                )
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.parallelNum = 1
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadCompleteMultipartUploadFail() async {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)
        
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 403,
                        headers: [:],
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "DELETE":
                return ResponseMessage(
                    statusCode: 206,
                    headers: [:]
                )
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadParallelUploadPartFail() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)
        
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 403,
                        headers: [:],
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "DELETE":
                return ResponseMessage(
                    statusCode: 206,
                    headers: [:]
                )
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploaderUploadFileEnableCheckpointNotUseCp() async throws {
        let file = Utils.createTestFile("test-file", 5 * 1024 * 1024 + 123)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.partSize = 1 * 1024 * 1024
            $0.parallelNum = 4
            $0.enableCheckpoint = true
            $0.checkpointDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        }
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        
        Utils.removeTestFile(file!)
    }
    
    func testMockUploaderUploadFileEnableCheckpointUseCp() async throws {
        let file = Utils.createTestFile("test-file", 5 * 1024 * 1024 + 123)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }
        let checkpointDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let srcHash = file!.data(using: .utf8)!.calculateMd5().hexString()
        let cpFilePath = checkpointDir! + "/\(srcHash)-d36fc07f5d963b319b1b48e20a9b8ae9\(Defaults.checkpointFileSuffixUploader)"

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)

        // consistent
        var mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    if requestMessage.requestUri.absoluteString.contains("partNumber=4") {
                        return ResponseMessage(
                            statusCode: 403,
                            headers: [:]
                        )
                    }
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(requestMessage.content!.hashCrc64ecma(crc: 0)!)]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        var client = Client(config) { $0.executeMW = mock }
        var uploader = Uploader(client) {
            $0.partSize = 1 * 1024 * 1024
            $0.parallelNum = 4
            $0.enableCheckpoint = true
            $0.checkpointDir = checkpointDir
        }
        if FileManager.default.fileExists(atPath: cpFilePath) {
            try FileManager.default.removeItem(atPath: cpFilePath)
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: cpFilePath))
        
        let parts = ArrayActor<Part>()
        mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    let crc = String(requestMessage.content!.hashCrc64ecma(crc: 0)!)
                    let string = requestMessage.requestUri.absoluteString.components(separatedBy: "partNumber=").last!
                    let partNumber = Int(string[string.startIndex..<string.index(string.startIndex, offsetBy: 1)])
                    await parts.append(
                        Part(
                            etag: "etag",
                            partNumber: partNumber,
                            hashCrc64: crc
                        )
                    )
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": crc]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "GET":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    var body = "<ListPartsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">"
                    body.append("<Bucket>multipart_upload</Bucket>")
                    body.append("<Key>multipart.data</Key>")
                    body.append("<UploadId>0004B999EF5A239BB9138C6227D6****</UploadId>")
                    body.append("<IsTruncated>false</IsTruncated>")
                    for part in await parts.elements {
                        body.append("<Part>")
                        body.append("<PartNumber>\(part.partNumber!)</Bucket>")
                        body.append("<ETag>\(part.etag!)</Bucket>")
                        body.append("<HashCrc64ecma>\(part.hashCrc64!)</Bucket>")
                        body.append("</Part>")
                    }
                    body.append("</ListPartsResult>")
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(body.data(using: .utf8)!)
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        client = Client(config) { $0.executeMW = mock }
        uploader = Uploader(client) {
            $0.partSize = 1 * 1024 * 1024
            $0.parallelNum = 4
            $0.enableCheckpoint = true
            $0.checkpointDir = checkpointDir
        }
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: cpFilePath))

        Utils.removeTestFile(file!)
    }
    
    func testMockUploadCRC64Fail() async throws {
        let file = Utils.createTestFile("test-file", 10 * 1024 * 1024)
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }
        
        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        var config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
        
        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": "123"]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        var client = Client(config) { $0.executeMW = mock }
        var uploader = Uploader(client) {
            $0.leavePartsOnError = true
        }
        
        await assertThrowsAsyncError(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.code, "InconsistentError")
        }
        
        // disable check crc
        config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withUploadCRC64Validation(false)
        client = Client(config) { $0.executeMW = mock }
        uploader = Uploader(client)
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: "bucket",
                key: "key",
                body: .file(URL(fileURLWithPath: file!))
            )
        )) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        Utils.removeTestFile(file!)
    }
    
    func testMockUploadSinglePartFromFileWithProgress() async throws {
        let size: Int64 = 1 * 1024 * 1024 + 123
        let partSize: Int64 = 256 * 1024
        let file = Utils.createTestFile("test-file", Int(size))
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)
            .withDownloadCRC64Validation(true)

        // consistent
        let mock = MockProcessRequest { requestMessage, context in
            XCTAssertEqual(requestMessage.method, "PUT")
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploads"))
            XCTAssertFalse(requestMessage.requestUri.absoluteString.contains("uploadId"))
            Task {
                var transferred: Int64 = 0
                repeat {
                    let part = (transferred + partSize > size) ? (size - transferred) : partSize
                    transferred += part
                    var progressDelegate = context.progressDelegate?.delegate
                    progressDelegate?.onProgress(part, transferred, size)
                } while transferred >= size
            }
            return ResponseMessage(
                statusCode: 200,
                headers: ["x-oss-hash-crc64ecma": String(crc)],
            )
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client)
        
        var request = PutObjectRequest(
            bucket: "bucket",
            key: "key",
            body: .file(URL(fileURLWithPath: file!))
        )
        nonisolated(unsafe) var transferred: Int64 = 0
        request.progress = ProgressClosure { bytesIncrement, totalBytesTransferred, totalBytesExpected in
            let part = (transferred + bytesIncrement > size) ? (size - transferred) : bytesIncrement
            XCTAssertEqual(bytesIncrement, part)
            XCTAssertEqual(totalBytesExpected, size)
            transferred += bytesIncrement
            XCTAssertEqual(transferred, totalBytesTransferred)
        }
        await assertNoThrow(try await uploader.upload(request))
        Utils.removeTestFile(file!)
    }
    
    func testMockUploaderUploadFileEnableCheckpointUseCpProgress() async throws {
        let size: Int64 = 5 * 1024 * 1024 + 123
        let partSize: Int64 = 256 * 1024
        let file = Utils.createTestFile("test-file", Int(size))
        let data = try Data(contentsOf: URL(fileURLWithPath: file!))
        let crc = data.withUnsafeBytes {
            CRC64.default.crc64(crc: 0, buf: $0.baseAddress!, len: $0.count)
        }
        let checkpointDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let srcHash = file!.data(using: .utf8)!.calculateMd5().hexString()
        let cpFilePath = checkpointDir! + "/\(srcHash)-d36fc07f5d963b319b1b48e20a9b8ae9\(Defaults.checkpointFileSuffixUploader)"

        let credentialsProvider = StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        let config = Configuration.default()
            .withRegion("cn-hangzhou")
            .withCredentialsProvider(credentialsProvider)

        // consistent
        let parts = ArrayActor<Part>()
        let mock = MockProcessRequest { requestMessage, context in
            switch requestMessage.method {
            case "POST":
                if requestMessage.requestUri.absoluteString.contains("uploads") {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: [:],
                        content: .data(
                            """
                            <InitiateMultipartUploadResult>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <UploadId>uploadId-1234</UploadId>\
                            </InitiateMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": String(crc)],
                        content: .data(
                            """
                            <CompleteMultipartUploadResult>\
                            <EncodingType>url</EncodingType>\
                            <Location>bucket/key</Location>\
                            <Bucket>bucket</Bucket>\
                            <Key>key</Key>\
                            <ETag>etag</ETag>\
                            </CompleteMultipartUploadResult>
                            """.data(using: .utf8)!
                        )
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            case "PUT":
                if (requestMessage.requestUri.absoluteString.contains("uploadId=uploadId-1234")) {
                    let crc = String(requestMessage.content!.hashCrc64ecma(crc: 0)!)
                    let string = requestMessage.requestUri.absoluteString.components(separatedBy: "partNumber=").last!
                    let partNumber = Int(string[string.startIndex..<string.index(string.startIndex, offsetBy: 1)])
                    await parts.append(
                        Part(
                            etag: "etag",
                            partNumber: partNumber,
                            hashCrc64: crc
                        )
                    )
                    return ResponseMessage(
                        statusCode: 200,
                        headers: ["x-oss-hash-crc64ecma": crc]
                    )
                } else {
                    throw ClientError(code: "TestError", message: "upload error")
                }
            default:
                throw ClientError(code: "TestError", message: "upload error")
            }
        }
        let client = Client(config) { $0.executeMW = mock }
        let uploader = Uploader(client) {
            $0.partSize = Int(partSize)
            $0.parallelNum = 1
            $0.enableCheckpoint = true
            $0.checkpointDir = checkpointDir
        }
        if FileManager.default.fileExists(atPath: cpFilePath) {
            try FileManager.default.removeItem(atPath: cpFilePath)
        }
        
        var request = PutObjectRequest(
            bucket: "bucket",
            key: "key",
            body: .file(URL(fileURLWithPath: file!))
        )
        nonisolated(unsafe) var transferred: Int64 = 0
        request.progress = ProgressClosure { bytesIncrement, totalBytesTransferred, totalBytesExpected in
            let part = (transferred + partSize > size) ? (size - transferred) : partSize
            XCTAssertEqual(bytesIncrement, part)
            XCTAssertEqual(totalBytesExpected, size)
            transferred += bytesIncrement
            XCTAssertEqual(transferred, totalBytesTransferred)
        }
        
        await assertNoThrow(try await uploader.upload(request)) {
            XCTAssertEqual($0.uploadId, "uploadId-1234")
            XCTAssertEqual($0.hashCRC64, crc)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: cpFilePath))

        Utils.removeTestFile(file!)
    }
}

private class MockProcessRequest: ExecuteMiddleware {
    var process: (RequestMessage, ExecuteContext) async throws -> ResponseMessage
    init(process: @escaping (RequestMessage, ExecuteContext) async throws -> ResponseMessage) {
        self.process = process
    }

    public func execute(request: RequestMessage, context: ExecuteContext) async throws -> ResponseMessage {
        try await process(request, context)
    }

    func reset(process: @escaping (RequestMessage, ExecuteContext) async throws -> ResponseMessage) {
        self.process = process
    }
}
