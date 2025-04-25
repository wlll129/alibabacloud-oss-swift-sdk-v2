@testable import AlibabaCloudOSS
import XCTest

public struct SubRequest: RequestModel {
    public var commonProp: RequestModelProp = .init()
    public var bucket: String?
    public var key: String?
    public var acl: String?
    public var metadata: [String: String]?
    init(
        bucket: String? = nil,
        key: String? = nil,
        acl: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.bucket = bucket
        self.key = key
        self.acl = acl
        self.metadata = metadata
    }
}

public struct SubResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    public var headerStr: String? { return commonProp.headers?["x-oss-header-str"] }
    public var headerInt: Int? { return commonProp.headers?["x-oss-header-int"]?.toInt() }
    public var headerBool: Bool? { return commonProp.headers?["x-oss-header-bool"]?.toBool() }
}

final class ModelsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequestModel() throws {
        var request = SubRequest()
        XCTAssertNil(request.bucket)
        XCTAssertNil(request.key)
        XCTAssertNil(request.acl)
        XCTAssertNil(request.metadata)
        XCTAssertNotNil(request.commonProp)
        XCTAssertNil(request.commonProp.headers)
        XCTAssertNil(request.commonProp.parameters)

        // set header
        request.addHeader("X-oss-header-str", "true")
        request.addHeader("Content-Type", "text/plain")

        XCTAssertNotNil(request.commonProp.headers)
        XCTAssertEqual(request.commonProp.headers?["x-oss-header-str"], "true")
        XCTAssertEqual(request.commonProp.headers?["content-type"], "text/plain")

        // set parameter
        request.addParameter("Parm", "1")
        request.addParameter("parm", "2")
        request.addParameter("nil-param", nil)
        request.addParameter("empty-param", "")
        XCTAssertNotNil(request.commonProp.parameters)
        XCTAssertEqual(request.commonProp.parameters?["Parm"]!, "1")
        XCTAssertEqual(request.commonProp.parameters?["parm"]!, "2")
        XCTAssertEqual(request.commonProp.parameters?["nil-param"]!, nil)
        XCTAssertEqual(request.commonProp.parameters?["empty-param"]!, "")
    }

    func testResultModel() throws {
        var result = SubResult()
        XCTAssertEqual(0, result.statusCode)
        XCTAssertEqual(nil, result.headers)
        XCTAssertEqual("", result.requestId)
        XCTAssertEqual(nil, result.headerStr)
        XCTAssertEqual(nil, result.headerInt)
        XCTAssertEqual(nil, result.headerBool)

        result.commonProp.statusCode = 200
        result.commonProp.headers = [
            "x-oss-header-str": "str-123",
            "x-oss-header-int": "123",
            "x-oss-header-bool": "true",
            "x-oss-request-id": "id-123",
        ]

        XCTAssertEqual(200, result.statusCode)
        XCTAssertNotNil(result.headers)
        XCTAssertEqual("str-123", result.headerStr)
        XCTAssertEqual(123, result.headerInt)
        XCTAssertEqual(true, result.headerBool)
        XCTAssertEqual("id-123", result.requestId)
    }
}
