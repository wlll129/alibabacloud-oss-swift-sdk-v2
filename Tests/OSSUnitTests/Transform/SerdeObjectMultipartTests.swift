
@testable import AlibabaCloudOSS
import XCTest

class SerdeObjectMultipartTests: XCTestCase {
    func testSerializeInitiateMultipartUpload() throws {
        var input = OperationInput()

        var request = InitiateMultipartUploadRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeInitiateMultipartUpload])
        XCTAssertNil(input.headers["x-oss-forbid-overwrite"])
        XCTAssertNil(input.headers["x-oss-storage-class"])
        XCTAssertNil(input.headers["x-oss-tagging"])
        XCTAssertNil(input.headers["x-oss-server-side-encryption"])
        XCTAssertNil(input.headers["x-oss-server-side-data-encryption"])
        XCTAssertNil(input.headers["x-oss-server-side-encryption-key-id"])
        XCTAssertNil(input.headers["Cache-Control"])
        XCTAssertNil(input.headers["Content-Disposition"])
        XCTAssertNil(input.headers["Content-Encoding"])
        XCTAssertNil(input.headers["Expires"])
        XCTAssertNil(input.parameters["encoding-type"] as Any?)

        // normal
        input = OperationInput()
        request = InitiateMultipartUploadRequest()
        request.forbidOverwrite = true
        request.storageClass = "Archive"
        request.tagging = "tagging"
        request.serverSideEncryption = "AES256"
        request.serverSideEncryptionKeyId = "9468da86-3509-4f8d-a61e-6eab1eac****"
        request.serverSideDataEncryption = "SM4"
        request.cacheControl = "no-cache"
        request.contentEncoding = "utf-8"
        request.contentDisposition = "a"
        request.expires = "expires"
        request.encodingType = "url"
        try Serde.serializeInput(&request, &input, [Serde.serializeInitiateMultipartUpload])
        XCTAssertEqual(input.headers["x-oss-forbid-overwrite"], request.forbidOverwrite?.toString())
        XCTAssertEqual(input.headers["x-oss-storage-class"], request.storageClass)
        XCTAssertEqual(input.headers["x-oss-tagging"], request.tagging)
        XCTAssertEqual(input.headers["x-oss-server-side-encryption"], request.serverSideEncryption)
        XCTAssertEqual(input.headers["x-oss-server-side-data-encryption"], request.serverSideDataEncryption)
        XCTAssertEqual(input.headers["x-oss-server-side-encryption-key-id"], request.serverSideEncryptionKeyId)
        XCTAssertEqual(input.headers["Cache-Control"], request.cacheControl)
        XCTAssertEqual(input.headers["Content-Disposition"], request.contentDisposition)
        XCTAssertEqual(input.headers["Content-Encoding"], request.contentEncoding)
        XCTAssertEqual(input.headers["Expires"], request.expires)
        XCTAssertEqual(input.parameters["encoding-type"], request.encodingType)
    }

    func testDeserializeInitiateMultipartUpload() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = InitiateMultipartUploadResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeInitiateMultipartUpload])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Can not get response body.") ?? false)
        }
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.uploadId)
        XCTAssertNil(result.encodingType)

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = InitiateMultipartUploadResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeInitiateMultipartUpload])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Not found root tag <InitiateMultipartUploadResult>. ") ?? false)
        }
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.uploadId)
        XCTAssertNil(result.encodingType)

        // normal
        let bucket = "oss-example"
        let key = "/multipart.data"
        let uploadId = "0004B9894A22E5B1888A1E29F823****"
        let encodingType = "url"
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<InitiateMultipartUploadResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<Bucket>\(bucket)</Bucket>")
        xml.append("<Key>\(key)</Key>")
        xml.append("<UploadId>\(uploadId)</UploadId>")
        xml.append("<EncodingType>\(encodingType)</EncodingType>")
        xml.append("</InitiateMultipartUploadResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = InitiateMultipartUploadResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeInitiateMultipartUpload]))
        XCTAssertEqual(bucket, result.bucket)
        XCTAssertEqual(key, result.key)
        XCTAssertEqual(uploadId, result.uploadId)
        XCTAssertEqual(encodingType, result.encodingType)

        // url encode
        xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<InitiateMultipartUploadResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<Bucket>\(bucket)</Bucket>")
        xml.append("<Key>\(key.urlEncode()!)</Key>")
        xml.append("<UploadId>\(uploadId)</UploadId>")
        xml.append("<EncodingType>\(encodingType)</EncodingType>")
        xml.append("</InitiateMultipartUploadResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = InitiateMultipartUploadResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeInitiateMultipartUpload]))
        XCTAssertEqual(bucket, result.bucket)
        XCTAssertEqual(key, result.key)
        XCTAssertEqual(uploadId, result.uploadId)
        XCTAssertEqual(encodingType, result.encodingType)
    }

    func testSerializeUploadPart() throws {
        var input = OperationInput()

        var request = UploadPartRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeUploadPart])
        XCTAssertNil(input.parameters["partNumber"] as Any?)
        XCTAssertNil(input.parameters["uploadId"] as Any?)
        XCTAssertNil(input.body)

        input = OperationInput()
        request = UploadPartRequest()
        request.partNumber = 1
        request.uploadId = "uploadId"
        request.body = .data("body".data(using: .utf8)!)
        try Serde.serializeInput(&request, &input, [Serde.serializeUploadPart])
        XCTAssertEqual(input.parameters["partNumber"], String(request.partNumber!))
        XCTAssertEqual(input.parameters["uploadId"], request.uploadId)
        XCTAssertEqual(try input.body?.readData()?.base64EncodedString(), try request.body?.readData()?.base64EncodedString())
    }

    func testSerializeCompleteMultipartUpload() throws {
        var input = OperationInput()
        var request = CompleteMultipartUploadRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeCompleteMultipartUpload])
        XCTAssertNil(input.headers["x-oss-forbid-overwrite"])
        XCTAssertNil(input.headers["x-oss-complete-all"])
        XCTAssertNil(input.parameters["uploadId"] as Any?)
        XCTAssertNil(input.parameters["encoding-type"] as Any?)
        XCTAssertNil(input.body)

        let parts = [UploadPart(etag: "etag1", partNumber: 1),
                     UploadPart(etag: "etag2", partNumber: 2)]
        input = OperationInput()
        request = CompleteMultipartUploadRequest()
        request.forbidOverwrite = true
        request.uploadId = "uploadId"
        request.completeAll = "yes"
        request.encodingType = "url"
        request.completeMultipartUpload = CompleteMultipartUpload(parts: parts)
        try Serde.serializeInput(&request, &input, [Serde.serializeCompleteMultipartUpload])
        XCTAssertEqual(input.headers["x-oss-forbid-overwrite"], request.forbidOverwrite?.toString())
        XCTAssertEqual(input.headers["x-oss-complete-all"], request.completeAll)
        XCTAssertEqual(input.parameters["uploadId"], request.uploadId)
        XCTAssertEqual(input.parameters["encoding-type"], request.encodingType)
        XCTAssertEqual(try input.body?.readData()?.base64EncodedString(), "<?xml version=\"1.0\" encoding=\"UTF-8\"?><CompleteMultipartUpload><Part><PartNumber>1</PartNumber><ETag>etag1</ETag></Part><Part><PartNumber>2</PartNumber><ETag>etag2</ETag></Part></CompleteMultipartUpload>".data(using: .utf8)?.base64EncodedString())
    }

    func testDeserializeCompleteMultipartUpload() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = CompleteMultipartUploadResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Can not get response body.") ?? false)
        }
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.etag)
        XCTAssertNil(result.location)
        XCTAssertNil(result.encodingType)

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = CompleteMultipartUploadResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Not found root tag <CompleteMultipartUploadResult>.") ?? false)
        }
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.etag)
        XCTAssertNil(result.location)
        XCTAssertNil(result.encodingType)

        // normal
        let encodingType = "url"
        let location = "http://oss-example.oss-cn-hangzhou.aliyuncs.com/multipart.data"
        let bucket = "oss-example"
        let key = "/multipart.data"
        let etag = "\"B864DB6A936D376F9F8D3ED3BBE540****\""
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<CompleteMultipartUploadResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<EncodingType>\(encodingType)</EncodingType>")
        xml.append("<Location>\(location)</Location>")
        xml.append("<Bucket>\(bucket)</Bucket>")
        xml.append("<Key>\(key)</Key>")
        xml.append("<ETag>\(etag)</ETag>")
        xml.append("</CompleteMultipartUploadResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = CompleteMultipartUploadResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload]))
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.key, key)
        XCTAssertEqual(result.etag, etag)
        XCTAssertEqual(result.location, location)
        XCTAssertEqual(result.encodingType, encodingType)

        // url encode
        xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<CompleteMultipartUploadResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<EncodingType>\(encodingType)</EncodingType>")
        xml.append("<Location>\(location)</Location>")
        xml.append("<Bucket>\(bucket)</Bucket>")
        xml.append("<Key>\(key.urlEncode()!)</Key>")
        xml.append("<ETag>\(etag)</ETag>")
        xml.append("</CompleteMultipartUploadResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = CompleteMultipartUploadResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload]))
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.key, key)
        XCTAssertEqual(result.etag, etag)
        XCTAssertEqual(result.location, location)
        XCTAssertEqual(result.encodingType, encodingType)

        // callback
        xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<CompleteMultipartUploadResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<EncodingType>\(encodingType)</EncodingType>")
        xml.append("<Location>\(location)</Location>")
        xml.append("<Bucket>\(bucket)</Bucket>")
        xml.append("<Key>\(key)</Key>")
        xml.append("<ETag>\(etag)</ETag>")
        xml.append("</CompleteMultipartUploadResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: ["x-oss-callback": "callback".data(using: .utf8)!.base64EncodedString()],
                                 body: .data(xml.data(using: .utf8)!))
        result = CompleteMultipartUploadResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload]))
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.etag)
        XCTAssertNil(result.location)
        XCTAssertNil(result.encodingType)
        XCTAssertNotNil(result.callbackResult)
    }

    func testSerializeUploadPartCopy() throws {
        var input = OperationInput()
        var request = UploadPartCopyRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeUploadPartCopy])
        XCTAssertNil(input.headers["x-oss-copy-source"])
        XCTAssertNil(input.headers["x-oss-copy-source-range"])
        XCTAssertNil(input.headers["x-oss-copy-source-if-match"])
        XCTAssertNil(input.headers["x-oss-copy-source-if-none-match"])
        XCTAssertNil(input.headers["x-oss-copy-source-if-unmodified-since"])
        XCTAssertNil(input.headers["x-oss-copy-source-if-modified-since"])
        XCTAssertNil(input.parameters["uploadId"] as Any?)
        XCTAssertNil(input.parameters["partNumber"] as Any?)

        input = OperationInput()
        request = UploadPartCopyRequest()
        request.sourceBucket = "sourceBucket"
        request.sourceKey = "sourceKey"
        request.copySourceIfMatch = "copySourceIfMatch"
        request.copySourceRange = "copySourceRange"
        request.copySourceIfNoneMatch = "copySourceIfNoneMatch"
        request.copySourceIfModifiedSince = "copySourceIfModifiedSince"
        request.copySourceIfUnmodifiedSince = "copySourceIfUnmodifiedSince"
        request.uploadId = "uploadId"
        request.partNumber = 1

        try Serde.serializeInput(&request, &input, [Serde.serializeUploadPartCopy])
        XCTAssertEqual(input.headers["x-oss-copy-source"], "/\(request.sourceBucket!)/\(request.sourceKey!)")
        XCTAssertEqual(input.headers["x-oss-copy-source-range"], request.copySourceRange)
        XCTAssertEqual(input.headers["x-oss-copy-source-if-match"], request.copySourceIfMatch)
        XCTAssertEqual(input.headers["x-oss-copy-source-if-none-match"], request.copySourceIfNoneMatch)
        XCTAssertEqual(input.headers["x-oss-copy-source-if-unmodified-since"], request.copySourceIfUnmodifiedSince)
        XCTAssertEqual(input.headers["x-oss-copy-source-if-modified-since"], request.copySourceIfModifiedSince)
        XCTAssertEqual(input.parameters["uploadId"], request.uploadId)
        XCTAssertEqual(input.parameters["partNumber"], String(request.partNumber!))
    }

    func testDeserializeUploadPartCopy() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = UploadPartCopyResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeUploadPartCopy])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Can not get response body.") ?? false)
        }
        XCTAssertNil(result.copyPartResult?.lastModified)
        XCTAssertNil(result.copyPartResult?.etag)

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = UploadPartCopyResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeUploadPartCopy])) {
            let clientError = $0 as? ClientError
            XCTAssertTrue(clientError?.message.contains("Not found root tag <CopyPartResult>.") ?? false)
        }
        XCTAssertNil(result.copyPartResult?.lastModified)
        XCTAssertNil(result.copyPartResult?.etag)

        // normal
        let etag = "\"5B3C1A2E053D763E1B002CC607C5****\""
        let lastModified = "2014-07-17T06:27:54.000Z"
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<CopyPartResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        xml.append("<LastModified>\(lastModified)</LastModified>")
        xml.append("<ETag>\(etag)</ETag>")
        xml.append("</CopyPartResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = UploadPartCopyResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeUploadPartCopy]))
        XCTAssertEqual(result.copyPartResult?.lastModified, DateFormatter.iso8601DateTimeSeconds.date(from: lastModified))
        XCTAssertEqual(result.copyPartResult?.etag, etag)
    }

    func testSerializeAbortMultipartUpload() throws {
        var input = OperationInput()
        var request = AbortMultipartUploadRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeAbortMultipartUpload])
        XCTAssertNil(input.parameters["uploadId"] as Any?)

        input = OperationInput()
        request = AbortMultipartUploadRequest()
        request.uploadId = "uploadId"
        try Serde.serializeInput(&request, &input, [Serde.serializeAbortMultipartUpload])
        XCTAssertEqual(input.parameters["uploadId"], request.uploadId)
    }

    func testSerializeListMultipartUploads() throws {
        var input = OperationInput()
        var request = ListMultipartUploadsRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeListMultipartUploads])
        XCTAssertNil(input.parameters["delimiter"] as Any?)
        XCTAssertNil(input.parameters["max-uploads"] as Any?)
        XCTAssertNil(input.parameters["key-marker"] as Any?)
        XCTAssertNil(input.parameters["prefix"] as Any?)
        XCTAssertNil(input.parameters["upload-id-marker"] as Any?)
        XCTAssertNil(input.parameters["encoding-type"] as Any?)

        input = OperationInput()
        request = ListMultipartUploadsRequest()
        request.delimiter = "uploadId"
        request.maxUploads = 100
        request.keyMarker = "uploadId"
        request.prefix = "uploadId"
        request.uploadIdMarker = "uploadId"
        request.encodingType = "uploadId"
        try Serde.serializeInput(&request, &input, [Serde.serializeListMultipartUploads])
        XCTAssertEqual(input.parameters["delimiter"], request.delimiter)
        XCTAssertEqual(input.parameters["max-uploads"], String(request.maxUploads!))
        XCTAssertEqual(input.parameters["key-marker"], request.keyMarker)
        XCTAssertEqual(input.parameters["prefix"], request.prefix)
        XCTAssertEqual(input.parameters["upload-id-marker"], request.uploadIdMarker)
        XCTAssertEqual(input.parameters["encoding-type"], request.encodingType)
    }

    func testDeserializeListMultipartUploads() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = ListMultipartUploadsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads]))
        XCTAssertNil(result.encodingType)
        XCTAssertNil(result.keyMarker)
        XCTAssertNil(result.uploadIdMarker)
        XCTAssertNil(result.isTruncated)
        XCTAssertNil(result.delimiter)
        XCTAssertNil(result.uploads)
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.nextKeyMarker)
        XCTAssertNil(result.nextUploadIdMarker)
        XCTAssertNil(result.maxUploads)
        XCTAssertNil(result.prefix)

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = ListMultipartUploadsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads]))
        XCTAssertNil(result.encodingType)
        XCTAssertNil(result.keyMarker)
        XCTAssertNil(result.uploadIdMarker)
        XCTAssertNil(result.isTruncated)
        XCTAssertNil(result.delimiter)
        XCTAssertNil(result.uploads)
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.nextKeyMarker)
        XCTAssertNil(result.nextUploadIdMarker)
        XCTAssertNil(result.maxUploads)
        XCTAssertNil(result.prefix)

        // normal
        let bucket = "oss-example"
        let keyMarker = "keyMarker/"
        let uploadIdMarker = "uploadIdMarker"
        let nextKeyMarker = "/oss.avi"
        let nextUploadIdMarker = "0004B99B8E707874FC2D692FA5D77D3F"
        let delimiter = "/delimiter"
        let prefix = "/prefix"
        let maxUploads = 1000
        let isTruncated = false
        let encodingType = "url"
        var uploads = [["Key": "/multipart.data",
                        "UploadId": "B999EF518A1FE585B0C9360DC4C8****",
                        "Initiated": "2012-02-23T04:18:23.000Z"],
                       ["Key": "oss.avi",
                        "UploadId": "0004B99B8E707874FC2D692FA5D7****",
                        "Initiated": "2012-02-23T06:14:27.000Z"],
                       ["Key": "/multipart1.data",
                        "UploadId": "0004B999EF5A239BB9138C6227D6****",
                        "Initiated": "2012-02-23T04:18:23.000Z"]]
        var bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListMultipartUploadsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<KeyMarker>\(keyMarker)</KeyMarker>")
        bodyString.append("<UploadIdMarker>\(uploadIdMarker)</UploadIdMarker>")
        bodyString.append("<NextKeyMarker>\(nextKeyMarker)</NextKeyMarker>")
        bodyString.append("<NextUploadIdMarker>\(nextUploadIdMarker)</NextUploadIdMarker>")
        bodyString.append("<Delimiter>\(delimiter)</Delimiter>")
        bodyString.append("<Prefix>\(prefix)</Prefix>")
        bodyString.append("<MaxUploads>\(maxUploads)</MaxUploads>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<EncodingType>\(encodingType)</EncodingType>")
        for upload in uploads {
            bodyString.append("<Upload><Key>\(upload["Key"]!)</Key>")
            bodyString.append("<UploadId>\(upload["UploadId"]!)</UploadId>")
            bodyString.append("<Initiated>\(upload["Initiated"]!)</Initiated></Upload>")
        }
        bodyString.append("</ListMultipartUploadsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListMultipartUploadsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads]))
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.keyMarker, keyMarker)
        XCTAssertEqual(result.uploadIdMarker, uploadIdMarker)
        XCTAssertEqual(result.nextKeyMarker, nextKeyMarker)
        XCTAssertEqual(result.nextUploadIdMarker, nextUploadIdMarker)
        XCTAssertEqual(result.delimiter, delimiter)
        XCTAssertEqual(result.prefix, prefix)
        XCTAssertEqual(result.maxUploads, maxUploads)
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.encodingType, encodingType)
        for upload in uploads {
            for resultUpload in result.uploads! {
                if resultUpload.uploadId == upload["UploadId"] {
                    XCTAssertEqual(upload["Key"], resultUpload.key)
                    XCTAssertEqual(DateFormatter.iso8601DateTimeSeconds.date(from: upload["Initiated"]!), resultUpload.initiated)
                }
            }
        }

        // url encode
        bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListMultipartUploadsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<KeyMarker>\(keyMarker.urlEncode()!)</KeyMarker>")
        bodyString.append("<UploadIdMarker>\(uploadIdMarker)</UploadIdMarker>")
        bodyString.append("<NextKeyMarker>\(nextKeyMarker.urlEncode()!)</NextKeyMarker>")
        bodyString.append("<NextUploadIdMarker>\(nextUploadIdMarker)</NextUploadIdMarker>")
        bodyString.append("<Delimiter>\(delimiter.urlEncode()!)</Delimiter>")
        bodyString.append("<Prefix>\(prefix.urlEncode()!)</Prefix>")
        bodyString.append("<MaxUploads>\(maxUploads)</MaxUploads>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<EncodingType>\(encodingType)</EncodingType>")
        for upload in uploads {
            bodyString.append("<Upload><Key>\(upload["Key"]!.urlEncode()!)</Key>")
            bodyString.append("<UploadId>\(upload["UploadId"]!)</UploadId>")
            bodyString.append("<Initiated>\(upload["Initiated"]!)</Initiated></Upload>")
        }
        bodyString.append("</ListMultipartUploadsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListMultipartUploadsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads]))
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.keyMarker, keyMarker)
        XCTAssertEqual(result.uploadIdMarker, uploadIdMarker)
        XCTAssertEqual(result.nextKeyMarker, nextKeyMarker)
        XCTAssertEqual(result.nextUploadIdMarker, nextUploadIdMarker)
        XCTAssertEqual(result.delimiter, delimiter)
        XCTAssertEqual(result.prefix, prefix)
        XCTAssertEqual(result.maxUploads, maxUploads)
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.encodingType, encodingType)
        for upload in uploads {
            for resultUpload in result.uploads! {
                if resultUpload.uploadId == upload["UploadId"] {
                    XCTAssertEqual(upload["Key"], resultUpload.key)
                    XCTAssertEqual(DateFormatter.iso8601DateTimeSeconds.date(from: upload["Initiated"]!), resultUpload.initiated)
                }
            }
        }

        // one result
        uploads = [["Key": "/multipart.data",
                    "UploadId": "B999EF518A1FE585B0C9360DC4C8****",
                    "Initiated": "2012-02-23T04:18:23.000Z"]]
        bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListMultipartUploadsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<KeyMarker>\(keyMarker)</KeyMarker>")
        bodyString.append("<UploadIdMarker>\(uploadIdMarker)</UploadIdMarker>")
        bodyString.append("<NextKeyMarker>\(nextKeyMarker)</NextKeyMarker>")
        bodyString.append("<NextUploadIdMarker>\(nextUploadIdMarker)</NextUploadIdMarker>")
        bodyString.append("<Delimiter>\(delimiter)</Delimiter>")
        bodyString.append("<Prefix>\(prefix)</Prefix>")
        bodyString.append("<MaxUploads>\(maxUploads)</MaxUploads>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<EncodingType>\(encodingType)</EncodingType>")
        for upload in uploads {
            bodyString.append("<Upload><Key>\(upload["Key"]!)</Key>")
            bodyString.append("<UploadId>\(upload["UploadId"]!)</UploadId>")
            bodyString.append("<Initiated>\(upload["Initiated"]!)</Initiated></Upload>")
        }
        bodyString.append("</ListMultipartUploadsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListMultipartUploadsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads]))
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.keyMarker, keyMarker)
        XCTAssertEqual(result.uploadIdMarker, uploadIdMarker)
        XCTAssertEqual(result.nextKeyMarker, nextKeyMarker)
        XCTAssertEqual(result.nextUploadIdMarker, nextUploadIdMarker)
        XCTAssertEqual(result.delimiter, delimiter)
        XCTAssertEqual(result.prefix, prefix)
        XCTAssertEqual(result.maxUploads, maxUploads)
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.encodingType, encodingType)
        for upload in uploads {
            for resultUpload in result.uploads! {
                if resultUpload.uploadId == upload["UploadId"] {
                    XCTAssertEqual(upload["Key"], resultUpload.key)
                    XCTAssertEqual(DateFormatter.iso8601DateTimeSeconds.date(from: upload["Initiated"]!), resultUpload.initiated)
                }
            }
        }
    }

    func testDeserializeListMultipartUploadsEncodingType() {
        var result = ListMultipartUploadsResult()
        result.bucket = "oss-example"
        result.keyMarker = "keyMarker%2F"
        result.uploadIdMarker = "uploadIdMarker"
        result.nextKeyMarker = "%2Foss.avi"
        result.nextUploadIdMarker = "0004B99B8E707874FC2D692FA5D77D3F"
        result.delimiter = "%2Fdelimiter"
        result.prefix = "%2Fprefix"
        result.maxUploads = 1000
        result.isTruncated = false
        result.encodingType = "url"
        result.uploads = [Upload(initiated: DateFormatter.iso8601DateTimeSeconds.date(from: "2012-02-23T04:18:23.000Z"), key: "%2Fmultipart.data", uploadId: "B999EF518A1FE585B0C9360DC4C8****"),
                          Upload(initiated: DateFormatter.iso8601DateTimeSeconds.date(from: "2012-02-23T06:14:27.000Z"), key: "%2Foss.avi", uploadId: "0004B99B8E707874FC2D692FA5D7****"),
                          Upload(initiated: DateFormatter.iso8601DateTimeSeconds.date(from: "2012-02-23T04:18:23.000Z"), key: "%2Fmultipart1.data", uploadId: "0004B999EF5A239BB9138C6227D6****")]
        var multableResult = result
        Serde.deserializeListMultipartUploadsEncodingType(result: &multableResult)
        XCTAssertEqual(result.bucket, multableResult.bucket)
        XCTAssertEqual(result.keyMarker?.replacingOccurrences(of: "%2F", with: "/"), multableResult.keyMarker)
        XCTAssertEqual(result.uploadIdMarker, multableResult.uploadIdMarker)
        XCTAssertEqual(result.nextUploadIdMarker?.replacingOccurrences(of: "%2F", with: "/"), multableResult.nextUploadIdMarker)
        XCTAssertEqual(result.delimiter?.replacingOccurrences(of: "%2F", with: "/"), multableResult.delimiter)
        XCTAssertEqual(result.prefix?.replacingOccurrences(of: "%2F", with: "/"), multableResult.prefix)
        XCTAssertEqual(result.maxUploads, multableResult.maxUploads)
        XCTAssertEqual(result.isTruncated, multableResult.isTruncated)
        XCTAssertEqual(result.encodingType, multableResult.encodingType)
        for upload in result.uploads! {
            for resultUpload in multableResult.uploads! {
                if resultUpload.uploadId == upload.uploadId {
                    XCTAssertEqual(upload.key?.replacingOccurrences(of: "%2F", with: "/"), resultUpload.key)
                    XCTAssertEqual(upload.initiated, resultUpload.initiated)
                }
            }
        }
    }

    func testSerializeListParts() throws {
        var input = OperationInput()
        var request = ListPartsRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeListParts])
        XCTAssertNil(input.parameters["uploadId"] as Any?)
        XCTAssertNil(input.parameters["max-parts"] as Any?)
        XCTAssertNil(input.parameters["part-number-marker"] as Any?)
        XCTAssertNil(input.parameters["encoding-type"] as Any?)

        input = OperationInput()
        request = ListPartsRequest()
        request.uploadId = "uploadId"
        request.maxParts = 100
        request.partNumberMarker = 100
        request.encodingType = "url"
        try Serde.serializeInput(&request, &input, [Serde.serializeListParts])
        XCTAssertEqual(input.parameters["uploadId"], request.uploadId)
        XCTAssertEqual(input.parameters["max-parts"], String(request.maxParts!))
        XCTAssertEqual(input.parameters["part-number-marker"], String(request.partNumberMarker!))
        XCTAssertEqual(input.parameters["encoding-type"], request.encodingType)
    }

    func testDeserializeListParts() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = ListPartsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListParts]))
        XCTAssertNil(result.maxParts)
        XCTAssertNil(result.isTruncated)
        XCTAssertNil(result.parts)
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.uploadId)
        XCTAssertNil(result.partNumberMarker)
        XCTAssertNil(result.nextPartNumberMarker)
        XCTAssertNil(result.encodingType)

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = ListPartsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListParts]))
        XCTAssertNil(result.maxParts)
        XCTAssertNil(result.isTruncated)
        XCTAssertNil(result.parts)
        XCTAssertNil(result.bucket)
        XCTAssertNil(result.key)
        XCTAssertNil(result.uploadId)
        XCTAssertNil(result.partNumberMarker)
        XCTAssertNil(result.nextPartNumberMarker)
        XCTAssertNil(result.encodingType)

        // normal
        let bucket = "oss-example"
        let key = "/multipart.data"
        let nextPartNumberMarker = 10
        let partNumberMarker = 5
        let maxParts = 1000
        let uploadId = "0004B99B8E707874FC2D692FA5D77D3F"
        let isTruncated = false
        let encodingType = "url"
        var uploads = [["PartNumber": "1",
                        "LastModified": "2012-02-23T07:01:34.000Z",
                        "ETag": "3349DC700140D7F86A0784842780****",
                        "Size": "6291456"],
                       ["PartNumber": "2",
                        "LastModified": "2012-02-23T07:01:34.000Z",
                        "ETag": "3349DC700140D7F86A0784842780****",
                        "Size": "6291456"],
                       ["PartNumber": "5",
                        "LastModified": "2012-02-23T07:01:34.000Z",
                        "ETag": "3349DC700140D7F86A0784842780****",
                        "Size": "1024"]]
        var bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListPartsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<Key>\(key.urlEncode()!)</Key>")
        bodyString.append("<UploadId>\(uploadId)</UploadId>")
        bodyString.append("<NextPartNumberMarker>\(nextPartNumberMarker)</NextPartNumberMarker>")
        bodyString.append("<PartNumberMarker>\(partNumberMarker)</PartNumberMarker>")
        bodyString.append("<MaxParts>\(maxParts)</MaxParts>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<EncodingType>\(encodingType)</EncodingType>")
        for upload in uploads {
            bodyString.append("<Part><PartNumber>\(upload["PartNumber"]!)</PartNumber>")
            bodyString.append("<LastModified>\(upload["LastModified"]!)</LastModified>")
            bodyString.append("<ETag>\(upload["ETag"]!)</ETag>")
            bodyString.append("<Size>\(upload["Size"]!)</Size></Part>")
        }
        bodyString.append("</ListPartsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListPartsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListParts]))
        XCTAssertEqual(result.maxParts, maxParts)
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.key, key)
        XCTAssertEqual(result.uploadId, uploadId)
        XCTAssertEqual(result.partNumberMarker, partNumberMarker)
        XCTAssertEqual(result.nextPartNumberMarker, nextPartNumberMarker)
        XCTAssertEqual(result.encodingType, encodingType)
        for upload in uploads {
            for resultUpload in result.parts! {
                if resultUpload.partNumber == Int(upload["PartNumber"]!) {
                    XCTAssertEqual(DateFormatter.iso8601DateTimeSeconds.date(from: upload["LastModified"]!), resultUpload.lastModified)
                    XCTAssertEqual(upload["ETag"], resultUpload.etag)
                    XCTAssertEqual(Int(upload["Size"]!), resultUpload.size)
                }
            }
        }

        // one result
        uploads = [["PartNumber": "1",
                    "LastModified": "2012-02-23T07:01:34.000Z",
                    "ETag": "3349DC700140D7F86A0784842780****",
                    "Size": "6291456"]]
        bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListPartsResult xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<Key>\(key.urlEncode()!)</Key>")
        bodyString.append("<UploadId>\(uploadId)</UploadId>")
        bodyString.append("<NextPartNumberMarker>\(nextPartNumberMarker)</NextPartNumberMarker>")
        bodyString.append("<PartNumberMarker>\(partNumberMarker)</PartNumberMarker>")
        bodyString.append("<MaxParts>\(maxParts)</MaxParts>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<EncodingType>\(encodingType)</EncodingType>")
        for upload in uploads {
            bodyString.append("<Part><PartNumber>\(upload["PartNumber"]!)</PartNumber>")
            bodyString.append("<LastModified>\(upload["LastModified"]!)</LastModified>")
            bodyString.append("<ETag>\(upload["ETag"]!)</ETag>")
            bodyString.append("<Size>\(upload["Size"]!)</Size></Part>")
        }
        bodyString.append("</ListPartsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListPartsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListParts]))
        XCTAssertEqual(result.maxParts, maxParts)
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.bucket, bucket)
        XCTAssertEqual(result.key, key)
        XCTAssertEqual(result.uploadId, uploadId)
        XCTAssertEqual(result.partNumberMarker, partNumberMarker)
        XCTAssertEqual(result.nextPartNumberMarker, nextPartNumberMarker)
        XCTAssertEqual(result.encodingType, encodingType)
        for upload in uploads {
            for resultUpload in result.parts! {
                if resultUpload.partNumber == Int(upload["PartNumber"]!) {
                    XCTAssertEqual(DateFormatter.iso8601DateTimeSeconds.date(from: upload["LastModified"]!), resultUpload.lastModified)
                    XCTAssertEqual(upload["ETag"], resultUpload.etag)
                    XCTAssertEqual(Int(upload["Size"]!), resultUpload.size)
                }
            }
        }
    }
}
