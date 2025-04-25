@testable import AlibabaCloudOSS
import XCTest

class SerdeBucketVersioningTests: XCTestCase {
    func testSerializePutBucketVersioning() {
        var input = OperationInput()

        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><VersioningConfiguration></VersioningConfiguration>"
        var request = PutBucketVersioningRequest(versioningConfiguration: VersioningConfiguration())
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializePutBucketVersioning]))
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))

        xml =
            """
            <?xml version=\"1.0\" encoding=\"UTF-8\"?>\
            <VersioningConfiguration>\
            <Status>Suspended</Status>\
            </VersioningConfiguration>
            """
        request = PutBucketVersioningRequest(versioningConfiguration: VersioningConfiguration(status: "Suspended"))
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializePutBucketVersioning]))
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))
    }

    func testDeserializeGetBucketVersioning() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetBucketVersioningResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketVersioning]))

        var xml = "<VersioningConfiguration xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\"/>"
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetBucketVersioningResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketVersioning]))
        XCTAssertNil(result.versioningConfiguration?.status)

        // normal
        xml =
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <VersioningConfiguration>\
            <Status>Enabled</Status>\
            </VersioningConfiguration>
            """
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetBucketVersioningResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketVersioning]))
        XCTAssertEqual(result.versioningConfiguration?.status, "Enabled")
    }

    func testSerializeListObjectVersions() {
        var input = OperationInput()

        var request = ListObjectVersionsRequest()
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializeListObjectVersions]))
        XCTAssertNil(input.headers["delimiter"])
        XCTAssertNil(input.headers["key-marker"])
        XCTAssertNil(input.headers["version-id-marker"])
        XCTAssertNil(input.headers["max-keys"])
        XCTAssertNil(input.headers["prefix"])
        XCTAssertNil(input.headers["encoding-type"])

        request = ListObjectVersionsRequest(delimiter: "delimiter",
                                            keyMarker: "keyMarker",
                                            versionIdMarker: "versionIdMarker",
                                            maxKeys: 100,
                                            prefix: "prefix",
                                            encodingType: "url")
        XCTAssertNoThrow(try Serde.serializeInput(&request, &input, [Serde.serializeListObjectVersions]))
        XCTAssertEqual(input.parameters["delimiter"], "delimiter")
        XCTAssertEqual(input.parameters["key-marker"], "keyMarker")
        XCTAssertEqual(input.parameters["version-id-marker"], "versionIdMarker")
        XCTAssertEqual(input.parameters["max-keys"], "100")
        XCTAssertEqual(input.parameters["prefix"], "prefix")
        XCTAssertEqual(input.parameters["encoding-type"], "url")
    }

    func testDeserializeListObjectVersions() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = ListObjectVersionsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjectVersions]))

        // normal
        var xml =
            """
            <ListVersionsResult>\
            <Name>examplebucket-1250000000</Name>\
            <Prefix>%2Fprefix</Prefix>\
            <KeyMarker>%2FkeyMarker</KeyMarker>\
            <NextKeyMarker>%2FnextKeyMarker</NextKeyMarker>\
            <VersionIdMarker>versionIdMarker</VersionIdMarker>\
            <NextVersionIdMarker>nextVersionIdMarker</NextVersionIdMarker>\
            <MaxKeys>1000</MaxKeys>\
            <IsTruncated>false</IsTruncated>\
            <DeleteMarker>\
            <Key>example</Key>\
            <VersionId>CAEQMxiBgICAof2D0BYiIDJhMGE3N2M1YTI1NDQzOGY5NTkyNTI3MGYyMzJm****</VersionId>\
            <IsLatest>false</IsLatest>\
            <LastModified>2019-04-09T07:27:28.000Z</LastModified>\
            <Owner>\
            <ID>1234512528586****</ID>\
            <DisplayName>12345125285864390</DisplayName>\
            </Owner>\
            </DeleteMarker>\
            <Version>\
            <VersionId>CAEQMxiBgMDNoP2D0BYiIDE3MWUxNzgxZDQxNTRiODI5OGYwZGMwNGY3MzZjN****</VersionId>\
            <Key>example-object-1.jpg</Key>\
            <IsLatest>false</IsLatest>\
            <LastModified>2019-08-5T12:03:10.000Z</LastModified>\  
            <ETag>5B3C1A2E053D763E1B669CC607C5A0FE1****</ETag>\
            <Size>10</Size>\
            <StorageClass>ARCHIVE</StorageClass>\
            <TransitionTime>2024-04-23T07:21:42.000Z</TransitionTime>\
            <RestoreInfo>ongoing-request="true"</RestoreInfo>\
            <Owner>\
            <ID>1250000000</ID>\
            <DisplayName>1250000000</DisplayName>\
            </Owner>\
            </Version>\
            <Version>\
            <Key>example-object-2.jpg</Key>\
            <VersionId>CAEQMxiBgMCZov2D0BYiIDY4MDllOTc2YmY5MjQxMzdiOGI3OTlhNTU0ODIx****</VersionId>\
            <IsLatest>true</IsLatest>\
            <LastModified>2019-08-9T12:03:09.000Z</LastModified>\
            <ETag>5B3C1A2E053D763E1B002CC607C5A0FE2****</ETag>\
            <Size>20</Size>\
            <StorageClass>STANDARD</StorageClass>\
            <Owner>\
            <ID>2250000000</ID>\
            <DisplayName>2250000000</DisplayName>\
            </Owner>\
            </Version>\
            <CommonPrefixes>
            <Prefix>commonPrefixes</Prefix>
            </CommonPrefixes>
            </ListVersionsResult>
            """

        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = ListObjectVersionsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjectVersions]))
        XCTAssertEqual(result.prefix, "%2Fprefix")
        XCTAssertEqual(result.keyMarker, "%2FkeyMarker")
        XCTAssertEqual(result.versionIdMarker, "versionIdMarker")
        XCTAssertEqual(result.nextKeyMarker, "%2FnextKeyMarker")
        XCTAssertEqual(result.nextVersionIdMarker, "nextVersionIdMarker")
        XCTAssertEqual(result.maxKeys, 1000)
        XCTAssertEqual(result.name, "examplebucket-1250000000")
        XCTAssertEqual(result.isTruncated, false)

        XCTAssertEqual(result.deleteMarkers?.count, 1)
        XCTAssertEqual(result.deleteMarkers?.first?.key, "example")
        XCTAssertEqual(result.deleteMarkers?.first?.versionId, "CAEQMxiBgICAof2D0BYiIDJhMGE3N2M1YTI1NDQzOGY5NTkyNTI3MGYyMzJm****")
        XCTAssertEqual(result.deleteMarkers?.first?.isLatest, false)
        XCTAssertEqual(result.deleteMarkers?.first?.lastModified, DateFormatter.iso8601DateTimeSeconds.date(from: "2019-04-09T07:27:28.000Z"))
        XCTAssertEqual(result.deleteMarkers?.first?.owner?.id, "1234512528586****")
        XCTAssertEqual(result.deleteMarkers?.first?.owner?.displayName, "12345125285864390")

        XCTAssertEqual(result.versions?.count, 2)
        XCTAssertEqual(result.versions?.first?.key, "example-object-1.jpg")
        XCTAssertEqual(result.versions?.first?.versionId, "CAEQMxiBgMDNoP2D0BYiIDE3MWUxNzgxZDQxNTRiODI5OGYwZGMwNGY3MzZjN****")
        XCTAssertEqual(result.versions?.first?.restoreInfo, "ongoing-request=\"true\"")
        XCTAssertEqual(result.versions?.first?.size, 10)
        XCTAssertEqual(result.versions?.first?.storageClass, "ARCHIVE")
        XCTAssertEqual(result.versions?.first?.transitionTime, DateFormatter.iso8601DateTimeSeconds.date(from: "2024-04-23T07:21:42.000Z"))
        XCTAssertEqual(result.versions?.first?.isLatest, false)
        XCTAssertEqual(result.versions?.first?.lastModified, DateFormatter.iso8601DateTimeSeconds.date(from: "2019-08-5T12:03:10.000Z"))
        XCTAssertEqual(result.versions?.first?.owner?.id, "1250000000")
        XCTAssertEqual(result.versions?.first?.owner?.displayName, "1250000000")
        XCTAssertEqual(result.versions?.last?.key, "example-object-2.jpg")
        XCTAssertEqual(result.versions?.last?.versionId, "CAEQMxiBgMCZov2D0BYiIDY4MDllOTc2YmY5MjQxMzdiOGI3OTlhNTU0ODIx****")
        XCTAssertNil(result.versions?.last?.restoreInfo)
        XCTAssertEqual(result.versions?.last?.size, 20)
        XCTAssertEqual(result.versions?.last?.storageClass, "STANDARD")
        XCTAssertNil(result.versions?.last?.transitionTime)
        XCTAssertEqual(result.versions?.last?.isLatest, true)
        XCTAssertEqual(result.versions?.last?.lastModified, DateFormatter.iso8601DateTimeSeconds.date(from: "2019-08-9T12:03:09.000Z"))
        XCTAssertEqual(result.versions?.last?.owner?.id, "2250000000")
        XCTAssertEqual(result.versions?.last?.owner?.displayName, "2250000000")

        XCTAssertEqual(result.commonPrefixes?.count, 1)
        XCTAssertEqual(result.commonPrefixes?.first?.prefix, "commonPrefixes")

        // url encode
        xml =
            """
            <ListVersionsResult>\
            <Name>examplebucket-1250000000</Name>\
            <Prefix>%2Fprefix</Prefix>\
            <KeyMarker>%2FkeyMarker</KeyMarker>\
            <NextKeyMarker>%2FnextKeyMarker</NextKeyMarker>\
            <VersionIdMarker>versionIdMarker</VersionIdMarker>\
            <NextVersionIdMarker>nextVersionIdMarker</NextVersionIdMarker>\
            <MaxKeys>1000</MaxKeys>\
            <IsTruncated>false</IsTruncated>\
            <EncodingType>url</EncodingType>\
            <Version>\
            <VersionId>CAEQMxiBgMDNoP2D0BYiIDE3MWUxNzgxZDQxNTRiODI5OGYwZGMwNGY3MzZjN****</VersionId>\
            <Key>%2Fexample-object-1.jpg</Key>\
            <IsLatest>false</IsLatest>\
            <LastModified>2019-08-5T12:03:10.000Z</LastModified>\  
            <ETag>5B3C1A2E053D763E1B669CC607C5A0FE1****</ETag>\
            <Size>10</Size>\
            <StorageClass>ARCHIVE</StorageClass>\
            <TransitionTime>2024-04-23T07:21:42.000Z</TransitionTime>\
            <RestoreInfo>ongoing-request="true"</RestoreInfo>\
            <Owner>\
            <ID>1250000000</ID>\
            <DisplayName>1250000000</DisplayName>\
            </Owner>\
            </Version>\
            </ListVersionsResult>
            """

        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = ListObjectVersionsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjectVersions]))
        XCTAssertEqual(result.prefix, "/prefix")
        XCTAssertEqual(result.keyMarker, "/keyMarker")
        XCTAssertEqual(result.versionIdMarker, "versionIdMarker")
        XCTAssertEqual(result.nextKeyMarker, "/nextKeyMarker")
        XCTAssertEqual(result.nextVersionIdMarker, "nextVersionIdMarker")
        XCTAssertEqual(result.maxKeys, 1000)
        XCTAssertEqual(result.name, "examplebucket-1250000000")
        XCTAssertEqual(result.isTruncated, false)
        XCTAssertEqual(result.encodingType, "url")

        XCTAssertEqual(result.versions?.count, 1)
        XCTAssertEqual(result.versions?.first?.key, "/example-object-1.jpg")
        XCTAssertEqual(result.versions?.first?.versionId, "CAEQMxiBgMDNoP2D0BYiIDE3MWUxNzgxZDQxNTRiODI5OGYwZGMwNGY3MzZjN****")
        XCTAssertEqual(result.versions?.first?.restoreInfo, "ongoing-request=\"true\"")
        XCTAssertEqual(result.versions?.first?.size, 10)
        XCTAssertEqual(result.versions?.first?.storageClass, "ARCHIVE")
        XCTAssertEqual(result.versions?.first?.transitionTime, DateFormatter.iso8601DateTimeSeconds.date(from: "2024-04-23T07:21:42.000Z"))
        XCTAssertEqual(result.versions?.first?.isLatest, false)
        XCTAssertEqual(result.versions?.first?.lastModified, DateFormatter.iso8601DateTimeSeconds.date(from: "2019-08-5T12:03:10.000Z"))
        XCTAssertEqual(result.versions?.first?.owner?.id, "1250000000")
        XCTAssertEqual(result.versions?.first?.owner?.displayName, "1250000000")
    }
}
