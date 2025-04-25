import Foundation

public struct SigningContext {
    public let bucket: String?
    public let key: String?
    public let product: String?
    public let region: String?
    public let additionalHeaderNames: [String]?
    public let subResource: [String]?

    public var expirationTime: Date?

    public var clockOffset: TimeInterval?

    // inout
    public var credentials: Credentials?
    public var signTime: Date?
    public var authHeader: Bool

    // out
    public var stringToSign: String
    public var dateToSign: String
    public var scopeToSign: String
    public var additionalHeadersToSign: String

    public init(bucket: String? = nil,
                key: String? = nil,
                region: String? = nil,
                product: String? = nil,
                signTime: Date? = nil,
                credentials: Credentials? = nil,
                additionalHeaderNames: [String]? = nil,
                subResource: [String]? = nil,
                expirationTime: Date? = nil,
                clockOffset: TimeInterval? = nil)
    {
        self.bucket = bucket
        self.key = key
        self.product = product
        self.region = region
        self.additionalHeaderNames = additionalHeaderNames
        self.credentials = credentials
        self.signTime = signTime
        self.expirationTime = expirationTime
        authHeader = true
        stringToSign = ""
        dateToSign = ""
        scopeToSign = ""
        additionalHeadersToSign = ""
        self.subResource = subResource
        self.clockOffset = clockOffset
    }
}
