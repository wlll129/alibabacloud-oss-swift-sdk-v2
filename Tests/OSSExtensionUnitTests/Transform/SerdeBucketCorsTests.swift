import AlibabaCloudOSS
@testable import AlibabaCloudOSSExtension
import XCTest

class SerdeBucketCorsTests: XCTestCase {
    func testSerializePutBucketCors() throws {
        var input = OperationInput()

        var xml = "<CORSConfiguration />"
        var request = PutBucketCorsRequest(corsConfiguration: CORSConfiguration())
        try Serde.serializeInput(&request, &input, [Serde.serializePutBucketCors])
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))

        xml =
            """
            <CORSConfiguration>\
            <CORSRule>\
            <AllowedOrigin>a1</AllowedOrigin>\
            <AllowedOrigin>b1</AllowedOrigin>\
            <AllowedMethod>c1</AllowedMethod>\
            <AllowedHeader>d1</AllowedHeader>\
            <ExposeHeader>e1</ExposeHeader>\
            <MaxAgeSeconds>1000</MaxAgeSeconds>\
            </CORSRule>\
            <CORSRule>\
            <AllowedOrigin>a2</AllowedOrigin>\
            <AllowedOrigin>b2</AllowedOrigin>\
            <AllowedMethod>c2</AllowedMethod>\
            <AllowedHeader>d2</AllowedHeader>\
            <ExposeHeader>e2</ExposeHeader>\
            <MaxAgeSeconds>2000</MaxAgeSeconds>\
            </CORSRule>\
            </CORSConfiguration>
            """
        let corsRules = [CORSRule(allowedOrigins: ["a1", "b1"], allowedMethods: ["c1"], allowedHeaders: ["d1"], exposeHeaders: ["e1"], maxAgeSeconds: 1000),
                         CORSRule(allowedOrigins: ["a2", "b2"], allowedMethods: ["c2"], allowedHeaders: ["d2"], exposeHeaders: ["e2"], maxAgeSeconds: 2000)]
        request = PutBucketCorsRequest(corsConfiguration: CORSConfiguration(corsRules: corsRules))
        try Serde.serializeInput(&request, &input, [Serde.serializePutBucketCors])
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))

        xml =
            """
            <CORSConfiguration>\
            <CORSRule>\
            <AllowedOrigin>a1</AllowedOrigin>\
            <AllowedOrigin>b1</AllowedOrigin>\
            <AllowedMethod>c1</AllowedMethod>\
            <AllowedHeader>d1</AllowedHeader>\
            <ExposeHeader>e1</ExposeHeader>\
            <MaxAgeSeconds>1000</MaxAgeSeconds>\
            </CORSRule>\
            <CORSRule>\
            <AllowedOrigin>a2</AllowedOrigin>\
            <AllowedOrigin>b2</AllowedOrigin>\
            <AllowedMethod>c2</AllowedMethod>\
            <AllowedHeader>d2</AllowedHeader>\
            <ExposeHeader>e2</ExposeHeader>\
            <MaxAgeSeconds>2000</MaxAgeSeconds>\
            </CORSRule>\
            <ResponseVary>true</ResponseVary>\
            </CORSConfiguration>
            """
        request = PutBucketCorsRequest(corsConfiguration: CORSConfiguration(corsRules: corsRules, responseVary: true))
        try Serde.serializeInput(&request, &input, [Serde.serializePutBucketCors])
        XCTAssertEqual(try input.body?.readData(), xml.data(using: .utf8))
    }

    func testDeserializeGetBucketCors() {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = GetBucketCorsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketCors]))

        // normal
        let xml =
            """
            <?xml version="1.0" encoding="UTF-8"?>\
            <CORSConfiguration>\
            <CORSRule>\
            <AllowedOrigin>*</AllowedOrigin>\
            <AllowedMethod>GET</AllowedMethod>\
            <AllowedMethod>PUT</AllowedMethod>\
            <AllowedHeader>*</AllowedHeader>\
            <ExposeHeader>x-oss-test</ExposeHeader>\
            <MaxAgeSeconds>100</MaxAgeSeconds>\
            </CORSRule>\
            <ResponseVary>false</ResponseVary>\
            </CORSConfiguration>
            """
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = GetBucketCorsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketCors]))
        XCTAssertEqual(result.corsConfiguration?.corsRules?.count, 1)
        XCTAssertTrue(result.corsConfiguration?.corsRules?.first?.allowedOrigins?.contains("*") ?? false)
        XCTAssertTrue(result.corsConfiguration?.corsRules?.first?.allowedMethods?.contains("GET") ?? false)
        XCTAssertTrue(result.corsConfiguration?.corsRules?.first?.allowedMethods?.contains("PUT") ?? false)
        XCTAssertTrue(result.corsConfiguration?.corsRules?.first?.allowedHeaders?.contains("*") ?? false)
        XCTAssertTrue(result.corsConfiguration?.corsRules?.first?.exposeHeaders?.contains("x-oss-test") ?? false)
        XCTAssertEqual(result.corsConfiguration?.corsRules?.first?.maxAgeSeconds, 100)
        XCTAssertEqual(result.corsConfiguration?.responseVary, false)
    }

    func testSerializeOptionObject() throws {
        var input = OperationInput()

        var request = OptionObjectRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeOptionObject])
        XCTAssertNil(input.headers["Origin"])
        XCTAssertNil(input.headers["Access-Control-Request-Method"])
        XCTAssertNil(input.headers["Access-Control-Request-Headers"])

        // normal
        request = OptionObjectRequest(origin: "origin",
                                      accessControlRequestMethod: "GET",
                                      accessControlRequestHeaders: "*")
        try Serde.serializeInput(&request, &input, [Serde.serializeOptionObject])
        XCTAssertEqual(input.headers["Origin"], "origin")
        XCTAssertEqual(input.headers["Access-Control-Request-Method"], "GET")
        XCTAssertEqual(input.headers["Access-Control-Request-Headers"], "*")
    }
}
