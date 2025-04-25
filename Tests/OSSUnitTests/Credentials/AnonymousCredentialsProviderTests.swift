import AlibabaCloudOSS
import XCTest

final class AnonymousCredentialsProviderTests: XCTestCase {
    func testAnonymousCredentialsProvider() async throws {
        let credentialsProvider = AnonymousCredentialsProvider()
        let credentials = try await credentialsProvider.getCredentials()

        XCTAssertEqual(credentials.accessKeyId, "")
        XCTAssertEqual(credentials.accessKeySecret, "")
        XCTAssertNil(credentials.securityToken)
        XCTAssertNil(credentials.expiration)
    }
}
