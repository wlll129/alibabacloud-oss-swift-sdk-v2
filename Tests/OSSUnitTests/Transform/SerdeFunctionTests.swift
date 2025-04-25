@testable import AlibabaCloudOSS
import XCTest

final class SerdeFunctionTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSerializeInput() throws {
        var request = PutApiRequest(
            bucket: "bucket",
            key: "key",
            acl: "private",
            metadata: ["key": "value", "key2": "value2"]
        )
        request.addHeader("x-oss-test-request", "request-test-123")
        request.addParameter("param-request", "request-param-123")

        var input = OperationInput(
            operationName: "PutApi",
            method: "PUT",
            headers: ["x-oss-test-input": "input-test-123"],
            parameters: ["param-input": "input-param-123"]
        )
        input.bucket = "bucket"
        input.key = "key"

        try Serde.serializeInput(
            &request,
            &input,
            [
                { request, input in
                    if let acl = request.acl {
                        input.headers["x-oss-acl"] = acl
                    }
                    request.metadata?.forEach { key, value in
                        input.headers["x-oss-meta-\(key)"] = value
                    }
                },
            ]
        )

        XCTAssertEqual("PutApi", input.operationName)
        XCTAssertEqual("bucket", input.bucket)
        XCTAssertEqual("key", input.key)
        XCTAssertEqual("input-test-123", input.headers["x-oss-test-input"])
        XCTAssertEqual("private", input.headers["x-oss-acl"])
        XCTAssertEqual("value", input.headers["x-oss-meta-key"])
        XCTAssertEqual("value2", input.headers["x-oss-meta-key2"])
        XCTAssertEqual("value2", input.headers["x-oss-meta-key2"])
        XCTAssertEqual("request-param-123", input.parameters["param-request"]!)
        XCTAssertEqual("input-param-123", input.parameters["param-input"]!)
        XCTAssertNil(input.body)
    }

    func testDeserializeOutput() throws {
        let xml = """
        <OutputXml>
            <StrValue>value1</StrValue>
            <StrValue1>12345</StrValue1>
        </OutputXml>
        """

        var output = OperationOutput(
            statusCode: 200,
            headers: [
                "x-oss-header-str": "str-123",
                "x-oss-header-int": "123",
                "x-oss-header-bool": "true",
                "x-oss-request-id": "id-123",
            ],
            body: .data(xml.data(using: .utf8)!)
        )

        var result = PutApiResult()

        try Serde.deserializeOutput(
            &result,
            &output,
            [
                { result, output in
                    guard let data = try output.body?.readData(),
                          let body = try Dictionary<String, Any>.withXMLData(data: data)["OutputXml"] as? [String: String]
                    else {
                        return
                    }
                    result.xmlResult = PutApiXmlResult()
                    result.xmlResult?.strValue = body["StrValue"]
                    result.xmlResult?.StrValue1 = body["StrValue1"]
                },
            ]
        )

        XCTAssertEqual(200, result.statusCode)
        XCTAssertNotNil(result.headers)
        XCTAssertEqual("str-123", result.headerStr)
        XCTAssertEqual(123, result.headerInt)
        XCTAssertEqual(true, result.headerBool)
        XCTAssertEqual("id-123", result.requestId)
        XCTAssertNotNil(result.xmlResult)
        XCTAssertEqual("value1", result.xmlResult?.strValue)
        XCTAssertEqual("12345", result.xmlResult?.StrValue1)
    }

    func testCaseInsensitiveKeyDictionary() {
        let dict: [String: String] = [
            "key1": "value1",
            "Content-Type": "value2",
        ]
        XCTAssertEqual("value1", dict["key1"])
        XCTAssertEqual("value2", dict["Content-Type"])
        XCTAssertNil(dict["Key1"])
        XCTAssertNil(dict["content-type"])

        XCTAssertEqual("value1", dict[caseInsensitive: "key1"])
        XCTAssertEqual("value2", dict[caseInsensitive: "Content-Type"])
        XCTAssertEqual("value1", dict[caseInsensitive: "Key1"])
        XCTAssertEqual("value2", dict[caseInsensitive: "content-type"])
        XCTAssertNil(dict["no-exist-key"])
    }

    func testDeserializeXmlSuccess() {
        let xml = """
        <OutputXml>
            <StrValue>value1</StrValue>
            <StrValue1>12345</StrValue1>
        </OutputXml>
        """

        XCTAssertNoThrow(try Serde.deserializeXml(.data(xml.data(using: .utf8)!), "OutputXml") as [String: Any])
        XCTAssertNoThrow(try Serde.deserializeXml(.data(xml.data(using: .utf8)!)) as [String: Any])
    }

    func testDeserializeXmlFail() {
        let xml = """
        <OutputXml>
            <StrValue>value1</StrValue>
            <StrValue1>12345</StrValue1>
        </OutputXml>
        """

        let invalidXml = """
        <OutputXml>
            <StrValue>value1</StrValue>
            <StrValue1>12345</StrValue1>
        """

        // nil ByteStream
        XCTAssertThrowsError(try Serde.deserializeXml(nil, "Root") as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Can not get response body.", clientError?.message.prefix(26))
        }
        XCTAssertThrowsError(try Serde.deserializeXml(nil) as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Can not get response body.", clientError?.message.prefix(26))
        }

        // empty ByteStream
        XCTAssertThrowsError(try Serde.deserializeXml(ByteStream.data(Data()), "Root") as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Not found root tag <Root>.", clientError?.message.prefix(26))
        }

        // invalid ByteStream
        XCTAssertThrowsError(try Serde.deserializeXml(ByteStream.stream(InputStream(data: Data())), "Root") as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Can not get response body.", clientError?.message.prefix(26))
        }
        XCTAssertThrowsError(try Serde.deserializeXml(ByteStream.stream(InputStream(data: Data()))) as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Can not get response body.", clientError?.message.prefix(26))
        }

        // no root element
        XCTAssertThrowsError(try Serde.deserializeXml(ByteStream.data(xml.data(using: .utf8)!), "") as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Null or empty field, xmlRoot.", clientError?.message.prefix(29))
        }

        // invalid xml
        XCTAssertThrowsError(try Serde.deserializeXml(ByteStream.data(invalidXml.data(using: .utf8)!), "OutputXml") as [String: Any]) {
            let clientError = $0 as? ClientError
            XCTAssertEqual("Parse response body fail.", clientError?.message.prefix(25))
        }
    }
}
