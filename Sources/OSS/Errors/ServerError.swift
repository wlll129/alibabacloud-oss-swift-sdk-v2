import Foundation

public struct ServerError: SdkErrorType {
    /// The status code of the response
    public let statusCode: Int

    /// The headers of the response
    public let headers: [String: String]

    /// information for errors, extact from response body
    public let errorFields: [String: String]

    /// The metohd and URL of the request
    public let requestTarget: String

    /// snapshot of the raw response body
    public let snapshot: Data?

    /// The time when this error occurred
    public let timestamp: Date

    /// The error code
    public var code: String {
        errorFields["Code"] ?? "BadErrorResponse"
    }

    /// The error message
    public var message: String {
        errorFields["Message"] ?? ""
    }

    /// The id that is used to identify the request.
    public var requestId: String {
        if let val = errorFields["RequestId"] {
            return val
        }
        if let val = headers[caseInsensitive: "x-oss-request-id"] {
            return val
        }
        return ""
    }

    /// A fine-grained error code. Each error cause corresponds to a unique error code.
    public var ec: String {
        if let val = errorFields["EC"] {
            return val
        }
        if let val = headers[caseInsensitive: "x-oss-ec"] {
            return val
        }
        return ""
    }

    /// Gets the Error instance that caused the current exception.
    public var innerError: Error? { nil }

    init(
        statusCode: Int,
        headers: [String: String],
        errorFields: [String: String],
        requestTarget: String,
        snapshot: Data?
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.errorFields = errorFields
        self.requestTarget = requestTarget
        self.snapshot = snapshot
        timestamp = Self.toServerTime(from: headers)
    }

    public var description: String {
        """
        Error returned by Service.
        Http Status Code: \(statusCode)
        Error Code: \(code)
        Request Id: \(requestId)
        Message: \(message)
        EC: \(ec)
        Timestamp: \(timestamp)
        Request Endpoint: \(requestTarget)
        """
    }

    private static func toServerTime(from headers: [String: String]) -> Date {
        var serverTime: Date? = nil
        if let dateStr = headers[caseInsensitive: "Date"] {
            serverTime = DateFormatter.rfc5322DateTime.date(from: dateStr)
        }
        return serverTime ?? Date()
    }
}
