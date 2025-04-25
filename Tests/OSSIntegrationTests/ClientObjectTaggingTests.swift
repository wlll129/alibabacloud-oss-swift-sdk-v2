import AlibabaCloudOSS
import XCTest

final class ClientObjectTaggingTests: BaseTestCase {
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

    // MARK: - test Tagging

    func testPutObjectTagging() async throws {
        let objectKey = "testPutObjectTagging"
        var tags: [String: String] = [:]

        var putObject = PutObjectRequest(bucket: bucketName,
                                         key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        var getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        var getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)

        tags = ["tagKey1": "tagValue1"]
        var requestTag: [Tag] = []
        for (key, value) in tags {
            requestTag.append(Tag(key: key, value: value))
        }

        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        var putObjectTaggingReqeust = PutObjectTaggingRequest(bucket: bucketName,
                                                              key: objectKey,
                                                              tagging: Tagging(tagSet: TagSet(tags: requestTag)))
        try await assertNoThrow(await client?.putObjectTagging(putObjectTaggingReqeust))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }

        tags = ["tagKey1": "tagValue1",
                "tagKey2": "tagValue2"]
        requestTag = []
        for (key, value) in tags {
            requestTag.append(Tag(key: key, value: value))
        }
        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        putObjectTaggingReqeust = PutObjectTaggingRequest(bucket: bucketName,
                                                          key: objectKey,
                                                          tagging: Tagging(tagSet: TagSet(tags: requestTag)))
        try await assertNoThrow(await client?.putObjectTagging(putObjectTaggingReqeust))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }
    }

    func testGetObjectTagging() async throws {
        let objectKey = "testGetObjectTagging"
        var tags: [String: String] = [:]

        var putObject = PutObjectRequest(bucket: bucketName,
                                         key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        var getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        var getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)

        tags = ["tagKey1": "tagValue1"]
        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        putObject.tagging = tags.encodedQuery()
        try await assertNoThrow(await client?.putObject(putObject))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }

        tags = ["tagKey1": "tagValue1",
                "tagKey2": "tagValue2"]
        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        putObject.tagging = tags.encodedQuery()
        try await assertNoThrow(await client?.putObject(putObject))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }
    }

    func testDeleteObjectTagging() async throws {
        let objectKey = "testPutObjectTagging"
        var tags: [String: String] = [:]

        var putObject = PutObjectRequest(bucket: bucketName,
                                         key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        var getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        var getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)

        var deleteObjectTaggingRequest = DeleteObjectTaggingRequest(bucket: bucketName, key: objectKey)
        try await assertNoThrow(await client?.deleteObjectTagging(deleteObjectTaggingRequest))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)

        tags = ["tagKey1": "tagValue1"]
        var requestTag: [Tag] = []
        for (key, value) in tags {
            requestTag.append(Tag(key: key, value: value))
        }

        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        var putObjectTaggingReqeust = PutObjectTaggingRequest(bucket: bucketName,
                                                              key: objectKey,
                                                              tagging: Tagging(tagSet: TagSet(tags: requestTag)))
        try await assertNoThrow(await client?.putObjectTagging(putObjectTaggingReqeust))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }

        deleteObjectTaggingRequest = DeleteObjectTaggingRequest(bucket: bucketName, key: objectKey)
        try await assertNoThrow(await client?.deleteObjectTagging(deleteObjectTaggingRequest))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)

        tags = ["tagKey1": "tagValue1",
                "tagKey2": "tagValue2"]
        requestTag = []
        for (key, value) in tags {
            requestTag.append(Tag(key: key, value: value))
        }
        putObject = PutObjectRequest(bucket: bucketName,
                                     key: objectKey)
        try await assertNoThrow(await client?.putObject(putObject))

        putObjectTaggingReqeust = PutObjectTaggingRequest(bucket: bucketName,
                                                          key: objectKey,
                                                          tagging: Tagging(tagSet: TagSet(tags: requestTag)))
        try await assertNoThrow(await client?.putObjectTagging(putObjectTaggingReqeust))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)

        for tag in getObjectTaggingResult!.tagging!.tagSet!.tags! {
            XCTAssertEqual(tags[tag.key!], tag.value)
        }

        deleteObjectTaggingRequest = DeleteObjectTaggingRequest(bucket: bucketName, key: objectKey)
        try await assertNoThrow(await client?.deleteObjectTagging(deleteObjectTaggingRequest))

        getObjectTaggingReqeust = GetObjectTaggingRequest(bucket: bucketName, key: objectKey)
        getObjectTaggingResult = try await client?.getObjectTagging(getObjectTaggingReqeust)
        XCTAssertEqual(getObjectTaggingResult?.statusCode, 200)
        XCTAssertEqual(getObjectTaggingResult?.tagging?.tagSet?.tags?.count, 0)
    }
}
