import Foundation

public struct Credentials: Sendable {
    /// The AccessKeyId property for the credentials.
    public let accessKeyId: String

    /// The AccessKeySecret property for the credentials.
    public let accessKeySecret: String

    /// The SecurityToken property for the credentials.
    public let securityToken: String?

    /// The token's expiration time.
    public let expiration: Date?

    /// Constructs a Credentials object with supplied accessKeyId, accessKeySecret and securityToken.
    /// - Parameters:
    ///   - accessKeyId: the access key id.
    ///   - accessKeySecret: the access key secret.
    ///   - securityToken: The security token, can be set to null or empty for non-session credentials.
    ///   - expiration: The token's expiration time.
    public init(
        accessKeyId: String,
        accessKeySecret: String,
        securityToken: String? = nil,
        expiration: Date? = nil
    ) {
        self.accessKeyId = accessKeyId
        self.accessKeySecret = accessKeySecret
        self.securityToken = securityToken
        self.expiration = expiration
    }
}

public extension Credentials {
    /// Will credential expire within a certain time
    func isExpiring(within interval: TimeInterval) -> Bool {
        if expiration == nil {
            return false
        }
        return expiration!.timeIntervalSinceNow < interval
    }

    /// Has credential expired
    var isExpired: Bool {
        isExpiring(within: 0)
    }

    /// Check whether the credentials keys are set
    func isEmpty() -> Bool {
        accessKeyId.isEmpty || accessKeySecret.isEmpty
    }
}
