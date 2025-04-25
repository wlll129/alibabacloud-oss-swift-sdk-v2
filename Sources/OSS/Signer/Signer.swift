import Foundation

public protocol Signer {
    func sign(request: RequestMessage, signingContext: inout SigningContext) async throws -> RequestMessage
}

public protocol SignatureDelegate {
    func signature(info: [String: String]) async throws -> [String: String]
}
