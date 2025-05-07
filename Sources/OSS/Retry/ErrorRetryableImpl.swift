import Foundation

public struct ServiceErrorRetryable: ErrorRetryable {
    static let statusCodes: [Int] = [401, 408, 429]
    static let errorCodes: [String] = ["RequestTimeTooSkewed", "BadRequest"]
    static let errorMessages: [String] = ["Invalid signing date in Authorization header."]
    
    public init() { }

    public func isErrorRetryable(error: Error) -> Bool {
        if let error = error as? ServerError {
            if Self.statusCodes.contains(error.statusCode) {
                return true
            }
            if error.statusCode >= 500 {
                return true
            }
            if Self.errorCodes.contains(error.code) {
                return true
            }
            if Self.errorMessages.contains(error.message) {
                return true
            }
        }

        return false
    }
}

public struct ClientErrorRetryable: ErrorRetryable {
    static let errorCodes: [String] = [
        "CredentialsFetchError",
        "InconsistentError",
        "SerdeError",
        "RemoteSignatureError",
        "ResponseError",
    ]
    
    public init() { }

    public func isErrorRetryable(error: Error) -> Bool {
        if let error = error as? ClientError {
            if Self.errorCodes.contains(error.code) {
                return true
            }
        }
        return false
    }
}
