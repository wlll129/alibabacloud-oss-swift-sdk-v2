import Foundation

public typealias GetCredentialsClosure = @Sendable () async throws -> Credentials

public struct ClosureCredentialsProvider: CredentialsProvider {
    private let closure: GetCredentialsClosure

    public init(closure: @escaping GetCredentialsClosure) {
        self.closure = closure
    }

    public func getCredentials() async throws -> Credentials {
        try await closure()
    }
}
