import Foundation

public protocol CredentialsProvider: Sendable {
    func getCredentials() async throws -> Credentials
}
