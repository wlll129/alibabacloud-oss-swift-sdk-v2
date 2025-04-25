
@testable import AlibabaCloudOSS
import XCTest

class SerdeServiceTests: XCTestCase {
    func testSerializeListBuckets() throws {
        var input = OperationInput()
        var request = ListBucketsRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeListBuckets])
        XCTAssertNil(input.headers["x-oss-resource-group-id"])
        XCTAssertNil(input.parameters["prefix"] as Any?)
        XCTAssertNil(input.parameters["marker"] as Any?)
        XCTAssertNil(input.parameters["max-keys"] as Any?)
        XCTAssertNil(input.parameters["tag-key"] as Any?)
        XCTAssertNil(input.parameters["tag-value"] as Any?)
        XCTAssertNil(input.parameters["tagging"] as Any?)

        request = ListBucketsRequest()
        request.resourceGroupId = "regions"
        request.prefix = "regions"
        request.marker = "regions"
        request.maxKeys = 100
        try Serde.serializeInput(&request, &input, [Serde.serializeListBuckets])
        XCTAssertEqual(input.headers["x-oss-resource-group-id"], request.resourceGroupId)
        XCTAssertEqual(input.parameters["prefix"], request.prefix)
        XCTAssertEqual(input.parameters["marker"], request.marker)
        XCTAssertEqual(input.parameters["max-keys"], String(request.maxKeys!))
    }

    func testDeserializeListBuckets() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = ListBucketsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListBuckets]))

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = ListBucketsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListBuckets]))

        // normal
        let ownerId = "512**"
        let ownerDisplayName = "51264"
        let isTruncated = true
        let marker = "1"
        let maxKeys = 100
        let nextMarker = "200"
        let prefix = "prefix"
        var buckets: [[String: String]] = [["CreationDate": "2014-02-17T18:12:43.000Z",
                                            "ExtranetEndpoint": "oss-cn-shanghai.aliyuncs.com",
                                            "IntranetEndpoint": "oss-cn-shanghai-internal.aliyuncs.com",
                                            "Location": "oss-cn-shanghai",
                                            "Name": "app-base-oss",
                                            "Region": "cn-shanghai",
                                            "StorageClass": "Standard"],
                                           ["CreationDate": "2014-02-25T11:21:04.000Z",
                                            "ExtranetEndpoint": "oss-cn-hangzhou.aliyuncs.com",
                                            "IntranetEndpoint": "oss-cn-hangzhou-internal.aliyuncs.com",
                                            "Location": "oss-cn-hangzhou",
                                            "Name": "mybucket",
                                            "Region": "cn-hangzhou",
                                            "StorageClass": "IA"],
                                           ["CreationDate": "2014-02-25T11:21:04.000Z",
                                            "ExtranetEndpoint": "oss-cn-hangzhou.aliyuncs.com",
                                            "IntranetEndpoint": "oss-cn-hangzhou-internal.aliyuncs.com",
                                            "Location": "oss-cn-hangzhou",
                                            "Name": "mybucket1",
                                            "Region": "cn-hangzhou",
                                            "StorageClass": "Archive"]]
        var bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListAllMyBucketsResult>")
        bodyString.append("<Prefix>\(prefix)</Prefix>")
        bodyString.append("<Marker>\(marker)</Marker>")
        bodyString.append("<MaxKeys>\(maxKeys)</MaxKeys>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<NextMarker>\(nextMarker)</NextMarker>")
        bodyString.append("<Owner>")
        bodyString.append("<ID>\(ownerId)</ID>")
        bodyString.append("<DisplayName>\(ownerDisplayName)</DisplayName>")
        bodyString.append("</Owner>")
        bodyString.append("<Buckets>")
        for bucket in buckets {
            bodyString.append("<Bucket>")
            bodyString.append("<CreationDate>\(bucket["CreationDate"]!)</CreationDate>")
            bodyString.append("<ExtranetEndpoint>\(bucket["ExtranetEndpoint"]!)</ExtranetEndpoint>")
            bodyString.append("<IntranetEndpoint>\(bucket["IntranetEndpoint"]!)</IntranetEndpoint>")
            bodyString.append("<Location>\(bucket["Location"]!)</Location>")
            bodyString.append("<Name>\(bucket["Name"]!)</Name>")
            bodyString.append("<Region>\(bucket["Region"]!)</Region>")
            bodyString.append("<StorageClass>\(bucket["StorageClass"]!)</StorageClass>")
            bodyString.append("</Bucket>")
        }
        bodyString.append("</Buckets>")
        bodyString.append("</ListAllMyBucketsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListBucketsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListBuckets]))
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.marker, marker)
        XCTAssertEqual(result.maxKeys, maxKeys)
        XCTAssertEqual(result.nextMarker, nextMarker)
        XCTAssertEqual(result.prefix, prefix)
        XCTAssertEqual(result.owner?.displayName, ownerDisplayName)
        XCTAssertEqual(result.owner?.id, ownerId)
        for bucket in buckets {
            for resultBucket in result.buckets! {
                if bucket["Name"] == resultBucket.name {
                    XCTAssertEqual(resultBucket.creationDate, DateFormatter.iso8601DateTimeSeconds.date(from: bucket["CreationDate"]!))
                    XCTAssertEqual(resultBucket.extranetEndpoint, bucket["ExtranetEndpoint"])
                    XCTAssertEqual(resultBucket.intranetEndpoint, bucket["IntranetEndpoint"])
                    XCTAssertEqual(resultBucket.location, bucket["Location"])
                    XCTAssertEqual(resultBucket.region, bucket["Region"])
                    XCTAssertEqual(resultBucket.storageClass, bucket["StorageClass"])
                }
            }
        }

        // one resule
        buckets = [["CreationDate": "2014-02-17T18:12:43.000Z",
                    "ExtranetEndpoint": "oss-cn-shanghai.aliyuncs.com",
                    "IntranetEndpoint": "oss-cn-shanghai-internal.aliyuncs.com",
                    "Location": "oss-cn-shanghai",
                    "Name": "app-base-oss",
                    "Region": "cn-shanghai",
                    "StorageClass": "Standard"]]
        bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListAllMyBucketsResult>")
        bodyString.append("<Prefix>\(prefix)</Prefix>")
        bodyString.append("<Marker>\(marker)</Marker>")
        bodyString.append("<MaxKeys>\(maxKeys)</MaxKeys>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        bodyString.append("<NextMarker>\(nextMarker)</NextMarker>")
        bodyString.append("<Owner>")
        bodyString.append("<ID>\(ownerId)</ID>")
        bodyString.append("<DisplayName>\(ownerDisplayName)</DisplayName>")
        bodyString.append("</Owner>")
        bodyString.append("<Buckets>")
        for bucket in buckets {
            bodyString.append("<Bucket>")
            bodyString.append("<CreationDate>\(bucket["CreationDate"]!)</CreationDate>")
            bodyString.append("<ExtranetEndpoint>\(bucket["ExtranetEndpoint"]!)</ExtranetEndpoint>")
            bodyString.append("<IntranetEndpoint>\(bucket["IntranetEndpoint"]!)</IntranetEndpoint>")
            bodyString.append("<Location>\(bucket["Location"]!)</Location>")
            bodyString.append("<Name>\(bucket["Name"]!)</Name>")
            bodyString.append("<Region>\(bucket["Region"]!)</Region>")
            bodyString.append("<StorageClass>\(bucket["StorageClass"]!)</StorageClass>")
            bodyString.append("</Bucket>")
        }
        bodyString.append("</Buckets>")
        bodyString.append("</ListAllMyBucketsResult>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(bodyString.data(using: .utf8)!))
        result = ListBucketsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeListBuckets]))
        XCTAssertEqual(result.isTruncated, isTruncated)
        XCTAssertEqual(result.marker, marker)
        XCTAssertEqual(result.maxKeys, maxKeys)
        XCTAssertEqual(result.nextMarker, nextMarker)
        XCTAssertEqual(result.prefix, prefix)
        XCTAssertEqual(result.owner?.displayName, ownerDisplayName)
        XCTAssertEqual(result.owner?.id, ownerId)
        for bucket in buckets {
            for resultBucket in result.buckets! {
                if bucket["Name"] == resultBucket.name {
                    XCTAssertEqual(resultBucket.creationDate, DateFormatter.iso8601DateTimeSeconds.date(from: bucket["CreationDate"]!))
                    XCTAssertEqual(resultBucket.extranetEndpoint, bucket["ExtranetEndpoint"])
                    XCTAssertEqual(resultBucket.intranetEndpoint, bucket["IntranetEndpoint"])
                    XCTAssertEqual(resultBucket.location, bucket["Location"])
                    XCTAssertEqual(resultBucket.region, bucket["Region"])
                    XCTAssertEqual(resultBucket.storageClass, bucket["StorageClass"])
                }
            }
        }
    }
}
