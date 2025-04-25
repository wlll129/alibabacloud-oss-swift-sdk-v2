import Foundation

public struct OperationInput: Sendable {
    public var operationName: Swift.String
    public var method: Swift.String
    public var headers: [Swift.String: Swift.String]
    public var parameters: [Swift.String: Swift.String?]
    public var body: ByteStream?

    public var bucket: Swift.String?
    public var key: Swift.String?

    public var metadata: Attributes

    public init(
        operationName: Swift.String = "",
        method: Swift.String = "",
        headers: [Swift.String: Swift.String]? = nil,
        parameters: [Swift.String: Swift.String?]? = nil,
        body: ByteStream? = nil,
        bucket: Swift.String? = nil,
        key: Swift.String? = nil
    ) {
        self.operationName = operationName
        self.method = method
        self.headers = headers ?? [:]
        self.parameters = parameters ?? [:]
        self.body = body
        self.bucket = bucket
        self.key = key
        metadata = Attributes()
    }
}
