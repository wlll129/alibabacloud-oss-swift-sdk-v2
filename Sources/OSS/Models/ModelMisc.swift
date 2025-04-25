import Foundation

/// The result for the presign operation.
public struct PresignResult: Sendable {
    /// The HTTP method, which corresponds to the operation.
    /// For example, the HTTP method of the GetObject operation is GET.
    public var method: String

    /// The pre-signed URL.
    public var url: String

    /// The time when the pre-signed URL expires.
    public var expiration: Foundation.Date?

    /// The request headers specified in the request.
    /// For example, if Content-Type is specified for PutObject, Content-Type is returned.
    public var signedHeaders: [Swift.String: Swift.String]?
}
