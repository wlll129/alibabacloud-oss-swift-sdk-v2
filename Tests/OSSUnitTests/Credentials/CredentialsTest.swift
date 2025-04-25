import AlibabaCloudOSS
import Foundation
import XCTest

class CredentialsTest: XCTestCase {
    func testCredentials() async throws {
        var cred = Credentials(accessKeyId: "ak", accessKeySecret: "sk")
        XCTAssertEqual("ak", cred.accessKeyId)
        XCTAssertEqual("sk", cred.accessKeySecret)
        XCTAssertNil(cred.securityToken)
        XCTAssertNil(cred.expiration)
        XCTAssertFalse(cred.isEmpty())
        XCTAssertFalse(cred.isExpired)

        cred = Credentials(accessKeyId: "ak", accessKeySecret: "sk", securityToken: "token")
        XCTAssertEqual("ak", cred.accessKeyId)
        XCTAssertEqual("sk", cred.accessKeySecret)
        XCTAssertEqual("token", cred.securityToken)
        XCTAssertNil(cred.expiration)
    }
}
