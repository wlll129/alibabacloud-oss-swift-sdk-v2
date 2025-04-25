import Foundation
import class Foundation.ProcessInfo

public struct EnvironmentCredentialsProvider: CredentialsProvider {
    public init() {}

    public func getCredentials() async throws -> Credentials {
        guard let accessKeyId = ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_ID"],
              let accessKeySecret = ProcessInfo.processInfo.environment["OSS_ACCESS_KEY_SECRET"]
        else {
            throw ClientError.paramNullOrEmptyError(field: "Environment.OSS_ACCESS_KEY_ID")
        }

        let securityToken = ProcessInfo.processInfo.environment["OSS_SESSION_TOKEN"]
        return Credentials(accessKeyId: accessKeyId,
                           accessKeySecret: accessKeySecret,
                           securityToken: securityToken)
    }
}
