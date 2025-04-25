
@testable import AlibabaCloudOSS
import XCTest

final class ErrorsTests: XCTestCase {
    func testOperationError() throws {
        let error = ServerError(
            statusCode: 400,
            headers: [:],
            errorFields: [:],
            requestTarget: "",
            snapshot: nil
        )
        let opErr = ClientError.operationError(name: "GetObject", innerError: error)

        let err = "\(opErr)"
        XCTAssertTrue(err.contains("Operation GetObject raised a error"))
        XCTAssertTrue(err.contains("Error returned by Service"))
        XCTAssertTrue(err.contains("Error Code: BadErrorResponse"))
        XCTAssertTrue(err.contains("Timestamp: 202"))
    }
}
