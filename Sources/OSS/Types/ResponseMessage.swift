import Foundation

public struct ResponseMessage {
    public var statusCode: Swift.Int

    public var headers: [Swift.String: Swift.String]

    public var content: ByteStream?

    public var request: RequestMessage?

    public init(
        statusCode: Swift.Int = 0,
        headers: [Swift.String: Swift.String] = [:],
        content: ByteStream? = nil,
        request: RequestMessage? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.content = content
        self.request = request
    }
}

extension ResponseMessage: CustomStringConvertible {
    public var description: String {
        if let request = request {
            """
            response\n\
            request url: \(request.requestUri)\n\
            status code: \(statusCode)\n\
            header: \(headers.map {
                "\($0.key): \($0.value)"
            }.joined(separator: "\n\t\t"))
            """
        } else {
            """
            response\n\
            status code: \(statusCode)\n\
            header: \(headers.map {
                "\($0.key): \($0.value)"
            }.joined(separator: "\n\t\t"))
            """
        }
    }
}
