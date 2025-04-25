import Foundation

public struct OperationOutput: Sendable {
    public let input: OperationInput?
    public let statusCode: Swift.Int
    public let headers: [Swift.String: Swift.String]
    public var body: ByteStream?

    public init(
        input: OperationInput? = nil,
        statusCode: Swift.Int,
        headers: [Swift.String: Swift.String],
        body: ByteStream? = nil
    ) {
        self.input = input
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }
}
