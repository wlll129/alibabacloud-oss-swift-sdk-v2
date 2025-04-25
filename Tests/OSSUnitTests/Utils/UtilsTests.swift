@testable import AlibabaCloudOSS
import XCTest

class UtilsTests: XCTestCase {
    func testVerifyEffectivenessOfBucketName() throws {
        let bucketName1 = "examplebucket1"
        let bucketName2 = "test-bucket-2021"
        let bucketName3 = "aliyun-oss-bucket"

        let bucketName4 = "Examplebucket1"
        let bucketName5 = "test_bucket_2021"
        let bucketName6 = "aliyun-oss-bucket-"

        XCTAssertTrue(try bucketName1.isValidBucketName())
        XCTAssertTrue(try bucketName2.isValidBucketName())
        XCTAssertTrue(try bucketName3.isValidBucketName())

        XCTAssertFalse(try bucketName4.isValidBucketName())
        XCTAssertFalse(try bucketName5.isValidBucketName())
        XCTAssertFalse(try bucketName6.isValidBucketName())
    }

    func testIsIPAddress() {
        let ipv4 = "192.168.1.1"
        let ipv6 = "fe80::200:ff:fe00:400"
        let host = "oss-cn-hangzhou.aliyuncs.com"
        let localhost = "localhost"

        XCTAssertTrue(ipv4.isIPAddress())
        XCTAssertTrue(ipv6.isIPAddress())

        XCTAssertFalse(host.isIPAddress())
        XCTAssertFalse(localhost.isIPAddress())
    }

    func testXMLParser() throws {
        // withXMLDataError
        var xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>".data(using: .utf8)
        var (root, error) = Dictionary<String, Any>.withXMLDataError(data: xmlBody!)
        XCTAssertNotNil(root["Delete"])
        if let delete = root["Delete"] as? [String: Any] {
            XCTAssertEqual(delete["Quiet"] as! String, "false")
            XCTAssertNotNil(delete["Object"] as? [Any])
            if let objects = delete["Object"] as? [[String: String]] {
                XCTAssertEqual(objects[0]["Key"], "multipart.data")
                XCTAssertEqual(objects[1]["Key"], "test.jpg")
                XCTAssertEqual(objects[2]["Key"], "demo.jpg")
            }
        }

        xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key>".data(using: .utf8)
        (root, error) = Dictionary<String, Any>.withXMLDataError(data: xmlBody!)
        XCTAssertNotNil(error)

        xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>".data(using: .utf8)
        (root, error) = Dictionary<String, Any>.withXMLDataError(data: xmlBody!)
        XCTAssertNotNil(error)

        // withXMLData
        xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>".data(using: .utf8)
        root = try Dictionary<String, Any>.withXMLData(data: xmlBody!)
        XCTAssertNotNil(root["Delete"])
        if let delete = root["Delete"] as? [String: Any] {
            XCTAssertEqual(delete["Quiet"] as! String, "false")
            XCTAssertNotNil(delete["Object"] as? [Any])
            if let objects = delete["Object"] as? [[String: String]] {
                XCTAssertEqual(objects[0]["Key"], "multipart.data")
                XCTAssertEqual(objects[1]["Key"], "test.jpg")
                XCTAssertEqual(objects[2]["Key"], "demo.jpg")
            }
        }

        xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><Quiet>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key>".data(using: .utf8)
        XCTAssertThrowsError(try Dictionary<String, Any>.withXMLData(data: xmlBody!))

        xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Delete><>false</Quiet><Object><Key>multipart.data</Key></Object><Object><Key>test.jpg</Key></Object><Object><Key>demo.jpg</Key></Object></Delete>".data(using: .utf8)
        XCTAssertThrowsError(try Dictionary<String, Any>.withXMLData(data: xmlBody!))
    }

    func testEscape() {
        let string1 = "abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],./-_=+"
        let string2 = "abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],\'.\"/<->_&=+"
        let escapeString2 = "abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890一\\[],&apos;.&quot;/&lt;-&gt;_&amp;=+"

        XCTAssertEqual(string1, string1.escape())
        XCTAssertEqual(escapeString2, string2.escape())
    }

    func testEncodedQuery() {
        var parameters: [String: String] = [:]

        XCTAssertEqual("", parameters.encodedQuery())

        parameters = ["key": "value"]
        XCTAssertEqual("key=value", parameters.encodedQuery())

        parameters = ["key1": "value1",
                      "key2": "value2"]
        XCTAssertTrue(parameters.encodedQuery() == "key1=value1&key2=value2" || parameters.encodedQuery() == "key2=value2&key1=value1")
    }

    func testURLEncode() {
        let string = "abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~/ *=+`!@#$%^&()\\|;':\",<>?"
        var urlEncodedString = string.urlEncode()
        XCTAssertEqual("abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~%2F%20%2A%3D%2B%60%21%40%23%24%25%5E%26%28%29%5C%7C%3B%27%3A%22%2C%3C%3E%3F", urlEncodedString)

        urlEncodedString = string.urlEncodeWithoutSeparator()
        XCTAssertEqual("abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_.~/%20%2A%3D%2B%60%21%40%23%24%25%5E%26%28%29%5C%7C%3B%27%3A%22%2C%3C%3E%3F", urlEncodedString)
    }

    func testToBase64JsonString() {
        var dic: [String: String] = ["key1": "value1",
                                     "key2": "value2"]
        var base64String = dic.toBase64JsonString()
        XCTAssertTrue(base64String == "eyJrZXkxIjoidmFsdWUxIiwia2V5MiI6InZhbHVlMiJ9" || base64String == "eyJrZXkyIjoidmFsdWUyIiwia2V5MSI6InZhbHVlMSJ9")

        dic = [:]
        base64String = dic.toBase64JsonString()
        XCTAssertEqual(base64String, "e30=")
    }

    func testToBase64String() {
        let base64String = "test method toBase64JsonString".data(using: .utf8)?.toBase64String()
        XCTAssertEqual(base64String, "dGVzdCBtZXRob2QgdG9CYXNlNjRKc29uU3RyaW5n")
    }

    func testCaseInsensitiveString() {
        var header: [CaseInsensitiveString: String] = [:]
        header["Key"] = "value1"
        XCTAssertEqual(header["key"], "value1")
        XCTAssertEqual(header["Key"], "value1")
        XCTAssertEqual(header["KEY"], "value1")

        header["key"] = "value2"
        XCTAssertEqual(header["key"], "value2")
        XCTAssertEqual(header["Key"], "value2")
        XCTAssertEqual(header["KEY"], "value2")
    }
}
