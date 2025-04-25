
@testable import AlibabaCloudOSS
import XCTest

class XmlParserTests: XCTestCase {
    func testXmlParser() {
        let bucket = "oss-example"
        let keyMarker = "keyMarker"
        let uploadIdMarker = "uploadIdMarker"
        let nextKeyMarker = "oss.avi"
        let nextUploadIdMarker = "0004B99B8E707874FC2D692FA5D77D3F"
        let delimiter = "delimiter"
        let prefix = "prefix"
        let maxUploads = 1000
        let isTruncated = false
        let uploads = [["Key": "multipart.data",
                        "UploadId": "B999EF518A1FE585B0C9360DC4C8****",
                        "Initiated": "2012-02-23T04:18:23.000Z"],
                       ["Key": "oss.avi",
                        "UploadId": "0004B99B8E707874FC2D692FA5D7****",
                        "Initiated": "2012-02-23T06:14:27.000Z"],
                       ["Key": "multipart.data",
                        "UploadId": "0004B999EF5A239BB9138C6227D6****",
                        "Initiated": "2012-02-23T04:18:23.000Z"]]
        var bodyString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        bodyString.append("<ListMultipartUploadsResultOld xmlns=\"http://doc.oss-cn-hangzhou.aliyuncs.com\">")
        bodyString.append("<Bucket>\(bucket)</Bucket>")
        bodyString.append("<KeyMarker>\(keyMarker)</KeyMarker>")
        bodyString.append("<UploadIdMarker>\(uploadIdMarker)</UploadIdMarker>")
        bodyString.append("<NextKeyMarker>\(nextKeyMarker)</NextKeyMarker>")
        bodyString.append("<NextUploadIdMarker>\(nextUploadIdMarker)</NextUploadIdMarker>")
        bodyString.append("<Delimiter>\(delimiter)</Delimiter>")
        bodyString.append("<Prefix>\(prefix)</Prefix>")
        bodyString.append("<MaxUploads>\(maxUploads)</MaxUploads>")
        bodyString.append("<IsTruncated>\(isTruncated)</IsTruncated>")
        for upload in uploads {
            bodyString.append("<Upload><Key>\(upload["Key"]!)</Key>")
            bodyString.append("<UploadId>\(upload["UploadId"]!)</UploadId>")
            bodyString.append("<Initiated>\(upload["Initiated"]!)</Initiated></Upload>")
        }
        bodyString.append("</ListMultipartUploadsResultOld>")

        let body: Data? = bodyString.data(using: .utf8)
        let parser = AlibabaCloudOSS.XmlParser()
        let result = parser.parse(data: body!)["ListMultipartUploadsResultOld"] as! [String: Any]

        XCTAssertEqual(result["Bucket"] as! String, bucket)
        XCTAssertEqual(result["KeyMarker"] as! String, keyMarker)
        XCTAssertEqual(result["UploadIdMarker"] as! String, uploadIdMarker)
        XCTAssertEqual(result["NextKeyMarker"] as! String, nextKeyMarker)
        XCTAssertEqual(result["NextUploadIdMarker"] as! String, nextUploadIdMarker)
        XCTAssertEqual(result["Delimiter"] as! String, delimiter)
        XCTAssertEqual(result["Prefix"] as! String, prefix)
        XCTAssertEqual(Int(result["MaxUploads"] as! String), maxUploads)
        XCTAssertEqual(Bool(result["IsTruncated"] as! String), isTruncated)
        for upload in uploads {
            for resultUpload in result["Upload"] as! [[String: String]] {
                if resultUpload["UploadId"] == upload["UploadId"] {
                    XCTAssertEqual(upload["Key"], resultUpload["Key"])
                    XCTAssertEqual(upload["Initiated"], resultUpload["Initiated"])
                }
            }
        }
    }
}
