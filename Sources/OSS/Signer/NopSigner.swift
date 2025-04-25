import Foundation

public struct NopSigner: Signer {
    public func sign(request: RequestMessage, signingContext _: inout SigningContext) async throws -> RequestMessage {
        return request
    }
}
