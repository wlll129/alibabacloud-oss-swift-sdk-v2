import Foundation

public struct StaticCredentialsProvider: CredentialsProvider {
    private let credentials: Credentials

    public init(
        accessKeyId: String,
        accessKeySecret: String,
        securityToken: String? = nil
    ) {
        credentials = Credentials(accessKeyId: accessKeyId,
                                  accessKeySecret: accessKeySecret,
                                  securityToken: securityToken)
    }

    public init(_ credentials: Credentials) {
        self.credentials = credentials
    }

    public func getCredentials() async throws -> Credentials {
        return credentials
    }
}
