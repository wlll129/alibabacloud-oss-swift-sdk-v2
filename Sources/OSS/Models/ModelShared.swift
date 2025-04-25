import Foundation

/// The class of the container that stores the ACL information.
public struct AccessControlList: Sendable {
    /// The ACL of the bucket.
    /// Sees BucketACLType for supported values.
    public var grant: Swift.String?

    public init(
        grant: Swift.String? = nil
    ) {
        self.grant = grant
    }
}

/// The container that stores the information about the bucket owner.
public struct Owner: Sendable {
    /// The ID of the bucket owner.
    public var id: Swift.String?

    /// The name of the bucket owner. The name of the bucket owner is the same as the ID of the bucket owner.
    public var displayName: Swift.String?

    public init(
        id: Swift.String? = nil,
        displayName: Swift.String? = nil
    ) {
        self.id = id
        self.displayName = displayName
    }
}

extension Owner: Codable {
    enum CodingKeys: String, CodingKey {
        case displayName = "DisplayName"
        case id = "ID"
    }
}

/// The container that stores the ACL information.
public struct AccessControlPolicy: Sendable {
    /// The class of the container that stores the ACL information.
    public var accessControlList: AccessControlList?

    /// The container that stores the information about the bucket owner.
    public var owner: Owner?

    public init(
        accessControlList: AccessControlList? = nil,
        owner: Owner? = nil
    ) {
        self.accessControlList = accessControlList
        self.owner = owner
    }
}

public struct Range {
    public let start: UInt64?
    public let end: UInt64?

    public init(start: UInt64?, end: UInt64?) {
        self.start = start
        self.end = end
    }

    public init?(rangeString: String) {
        let string = rangeString.replacingOccurrences(of: "bytes=", with: "")
        let startAndEnd = string.components(separatedBy: "-")
        guard startAndEnd.count == 2 else {
            return nil
        }

        start = UInt64(startAndEnd.first ?? "0")
        end = UInt64(startAndEnd.last ?? "0")
    }

    public static func from(_ start: UInt64) -> Range {
        return Range(start: start, end: nil)
    }

    public static func to(_ end: UInt64) -> Range {
        return Range(start: nil, end: end)
    }

    public func asString() -> String? {
        if start == nil, end == nil {
            return nil
        }
        var range = "bytes=\(start ?? 0)-"
        if let end = end {
            range.append("\(end)")
        }
        return range
    }
}

public struct Callback {
    public enum CallbackBodyType: String {
        case URLEncoded = "application/x-www-form-urlencoded"
        case JSON = "application/json"
    }

    /// the callback url
    ///
    /// The URL of the server to which OSS sends a callback request.
    /// After an object is uploaded, OSS uses the POST method to send a callback request to the URL.
    /// The body of the request is the content that is specified in callbackBody.
    /// In most cases, the server with the URL returns the HTTP/1.1 200 OK response.
    /// The response body must be in the JSON format, and the value of the Content-Length response header must be valid and smaller than 3 MB in size.
    public let callbackUrl: String

    /// The value of the Host header in the callback request.
    /// The value must comply with the naming conventions for domain names and IP addresses.
    /// This field takes effect only when you configure the callbackUrl field.
    /// If you do not configure the callbackHost field, the host value is resolved from the URL that is specified by the callbackUrl field and populated in this field.
    public var callbackHost: String?

    /// The value of the Content-Type header in the callback request.
    public var callbackBodyType: CallbackBodyType?

    /// The value of the callback request body.
    /// OSS system variables, custom variables, and constants are supported.
    /// The supported system variables: https://www.alibabacloud.com/help/en/object-storage-service/latest/callback
    public var callbackBody: String

    /// The custom parameters
    public var callbackVar: [String: String]?

    public init(callbackUrl: String, callbackBody: String) {
        self.callbackUrl = callbackUrl
        self.callbackBody = callbackBody
    }

    public func toDictionary() -> [String: Any] {
        var callback: [String: Any] = ["callbackUrl": callbackUrl]
        callback["callbackHost"] = callbackHost
        callback["callbackBodyType"] = callbackBodyType?.rawValue
        callback["callbackBody"] = callbackBody

        return callback
    }
}
