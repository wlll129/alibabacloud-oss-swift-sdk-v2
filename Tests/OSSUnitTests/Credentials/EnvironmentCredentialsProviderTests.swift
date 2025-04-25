import AlibabaCloudOSS
import class Foundation.ProcessInfo
import XCTest

class EnvironmentCredentialsProviderTests: XCTestCase {
    /*
     func testSuccess() async throws {
         let accessKeyId = "ak"
         let accessKeySecret = "sk"
         let securityToken = "token"

         let oldak = ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"],
         let oldsk = ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_SECRET"]
         let oldtoken = ProcessInfo.processInfo.environment["OSS_SESSION_TOKEN"]

         ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"] = accessKeyId
         ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_SECRET"] = accessKeySecret
         ProcessInfo.processInfo.environment["OSS_SESSION_TOKEN"] = securityToken
         defer {
             ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"] = oldak
             ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"] = oldsk
             ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"] = oldtoken
         }

         let provider = EnvironmentCredentialsProvider()
         let cred = try await provider.getCredentials()

         XCTAssertEqual("ak", cred.accessKeyId)
         XCTAssertEqual("sk", cred.accessKeySecret)
         XCTAssertEqual("token", cred.securityToken)
     }
     */
}
