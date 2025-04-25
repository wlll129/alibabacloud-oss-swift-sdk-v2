import Foundation

public struct AnonymousCredentialsProvider: CredentialsProvider {
    public init() {}

    public func getCredentials() async throws -> Credentials {
        return Credentials(accessKeyId: "", accessKeySecret: "")
    }
}
