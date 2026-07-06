import XCTest
import AlibabaCloudOSS

final class UploaderTests: BaseTestCase {
    
    override func setUp() async throws {
        try await super.setUp()

        client = getDefaultClient()
        bucketName = randomBucketName()

        let requst = PutBucketRequest(bucket: bucketName)
        try await assertNoThrow(await client?.putBucket(requst))
    }

    override func tearDown() async throws {
        try await cleanBucket(client: client!, bucket: bucketName)
        try await super.tearDown()
    }
    
    func testUploadMultiPart() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 20 * 1024 * 1024)
        
        let uploader = Uploader(client!)
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!))
            )
        ))
                
        try await isEqual(client: client!,
                          bucket: bucketName,
                          key: key,
                          localFile: file!)
        
        let headResult = try await client?.headObject(HeadObjectRequest(
            bucket: bucketName,
            key: key
        ))
        XCTAssertEqual("Multipart", headResult?.objectType)
        
        removeTestFile(file!)
    }
    
    func testUploadSinglePart() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 2 * 1024 * 1024)
        
        let uploader = Uploader(client!)
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!))
            )
        ))
                
        try await isEqual(client: client!,
                          bucket: bucketName,
                          key: key,
                          localFile: file!)
        
        let headResult = try await client?.headObject(HeadObjectRequest(
            bucket: bucketName,
            key: key
        ))
        XCTAssertEqual("Normal", headResult?.objectType)
        
        removeTestFile(file!)
    }
    
    func testUploadWithProgressListener() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 20 * 1024 * 1024)
        nonisolated(unsafe) var totalBytesSent: Int64 = 0
        
        let uploader = Uploader(client!) {
            $0.partSize = 1024 * 1024
        }
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!)),
                progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                    totalBytesSent += bytesIncrement
                    XCTAssertEqual(totalBytesSent, totalBytesTransferred)
                    XCTAssertEqual(1024 * 1024, bytesIncrement)
                    XCTAssertEqual(20 * 1024 * 1024, totalBytesExpected)
                })
            )
        ))
        
        XCTAssertEqual(20 * 1024 * 1024, totalBytesSent)
        removeTestFile(file!)
    }
    
    func testUploadWithEnableCheckPoint() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 20 * 1024 * 1024)
        
        let uploader = Uploader(client!) {
            $0.enableCheckpoint = true
            $0.partSize = 1024 * 1024
        }
        try await Task {
            nonisolated(unsafe) let task = withUnsafeCurrentTask { $0 }
            await assertThrowsAsyncError(try await uploader.upload(
                PutObjectRequest(
                    bucket: bucketName,
                    key: key,
                    body: .file(URL(fileURLWithPath: file!)),
                    progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                        if totalBytesTransferred > totalBytesExpected / 2 {
                            task?.cancel()
                        }
                    })
                )
            ))
        }.value
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!)),
                progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                    XCTAssertTrue(totalBytesTransferred > totalBytesExpected / 2)
                })
            )
        ))
                
        try await isEqual(client: client!,
                          bucket: bucketName,
                          key: key,
                          localFile: file!)
        
        removeTestFile(file!)
    }
    
    func testUploadWithCheckPointDir() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 20 * 1024 * 1024)
        let baseDir = "\(tempDir)\(pathSeparator)uploader"
        
        let uploader = Uploader(client!) {
            $0.enableCheckpoint = true
            $0.partSize = 1024 * 1024
            $0.checkpointDir = baseDir
        }
        try await Task {
            nonisolated(unsafe) let task = withUnsafeCurrentTask { $0 }
            await assertThrowsAsyncError(try await uploader.upload(
                PutObjectRequest(
                    bucket: bucketName,
                    key: key,
                    body: .file(URL(fileURLWithPath: file!)),
                    progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                        if totalBytesTransferred > totalBytesExpected / 2 {
                            task?.cancel()
                        }
                    })
                )
            ))
        }.value
        
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: baseDir, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertEqual(1, FileManager.default.enumerator(atPath: baseDir)?.allObjects.count)
        
        await assertNoThrow(try await uploader.upload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!)),
                progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                    XCTAssertTrue(totalBytesTransferred > totalBytesExpected / 2)
                })
            )
        ))
                
        try await isEqual(client: client!,
                          bucket: bucketName,
                          key: key,
                          localFile: file!)
        
        XCTAssertEqual(0, FileManager.default.enumerator(atPath: baseDir)?.allObjects.count)
        removeTestFile(file!)
    }
    
    func testUploadWithAbort() async throws {
        let key = randomObjectName()
        let file = createTestFile("test-file", 20 * 1024 * 1024)
        let baseDir = "\(tempDir)\(pathSeparator)uploader"
        
        let uploader = Uploader(client!) {
            $0.enableCheckpoint = true
            $0.partSize = 1024 * 1024
            $0.checkpointDir = baseDir
        }
        try await Task {
            nonisolated(unsafe) let task = withUnsafeCurrentTask { $0 }
            await assertThrowsAsyncError(try await uploader.upload(
                PutObjectRequest(
                    bucket: bucketName,
                    key: key,
                    body: .file(URL(fileURLWithPath: file!)),
                    progress: ProgressClosure(closure: { bytesIncrement, totalBytesTransferred, totalBytesExpected in
                        if totalBytesTransferred > totalBytesExpected / 2 {
                            task?.cancel()
                        }
                    })
                )
            ))
        }.value
        
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: baseDir, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
        XCTAssertEqual(1, FileManager.default.enumerator(atPath: baseDir)?.allObjects.count)
        
        await assertNoThrow(try await uploader.abortUpload(
            PutObjectRequest(
                bucket: bucketName,
                key: key,
                body: .file(URL(fileURLWithPath: file!))
            )
        ))
                
        let uploadsResult = try await client?.listMultipartUploads(ListMultipartUploadsRequest(
            bucket: bucketName
        ))
        XCTAssertEqual(uploadsResult?.uploads?.count, 0)
        XCTAssertEqual(0, FileManager.default.enumerator(atPath: baseDir)?.allObjects.count)
        removeTestFile(file!)
    }
    
    func testUploadWithException() async throws {
        let uploader = Uploader(client!)
        let invalidUploader = Uploader(getInvalidAkClient())
        await assertThrowsAsyncError(try await uploader.upload(PutObjectRequest())) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.bucket.")
        }
        
        await assertThrowsAsyncError(try await uploader.upload(PutObjectRequest(
            bucket: "bucket-name"
        ))) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.key.")
        }
        
        await assertThrowsAsyncError(try await uploader.upload(PutObjectRequest(
            bucket: "bucket-name",
            key: "key"
        ))) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.body.")
        }
        
        await assertThrowsAsyncError(try await invalidUploader.upload(PutObjectRequest(
            bucket: "bucket-name",
            key: "key",
            body: .data("Hello oss.".data(using: .utf8)!)
        ))) {
            let error = $0 as? ServerError
            XCTAssertEqual(error?.statusCode, 403)
        }
    }
    
    func testAbortUploadWithException() async throws {
        let uploader = Uploader(client!)
        await assertThrowsAsyncError(try await uploader.abortUpload(PutObjectRequest())) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.bucket.")
        }
        
        await assertThrowsAsyncError(try await uploader.abortUpload(PutObjectRequest(
            bucket: "bucket-name"
        ))) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.key.")
        }
        
        await assertThrowsAsyncError(try await uploader.abortUpload(PutObjectRequest(
            bucket: "bucket-name",
            key: "key"
        ))) {
            let error = $0 as? ClientError
            XCTAssertEqual(error?.message, "Missing required field, request.body.")
        }
    }
}
