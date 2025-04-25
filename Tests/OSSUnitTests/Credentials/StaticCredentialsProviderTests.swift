import AlibabaCloudOSS
import XCTest

final class StaticCredentialsProviderTests: XCTestCase {
    func testOSSStsTokenCredentialsProvider() async throws {
        let credentials = Credentials(accessKeyId: "accessKey",
                                      accessKeySecret: "secretKey",
                                      securityToken: "token",
                                      expiration: nil)
        let CredentialsProvider = StaticCredentialsProvider(accessKeyId: credentials.accessKeyId,
                                                            accessKeySecret: credentials.accessKeySecret,
                                                            securityToken: credentials.securityToken)
        let token = try await CredentialsProvider.getCredentials()
        XCTAssertEqual(credentials.accessKeyId, token.accessKeyId)
        XCTAssertEqual(credentials.accessKeySecret, token.accessKeySecret)
        XCTAssertEqual(credentials.securityToken, token.securityToken)
    }
}
