import Foundation

public struct RequestMessage {
    public var method: Swift.String

    public var requestUri: URL

    /// HTTP headers in lower key
    public var headers: [Swift.String: Swift.String]

    public var content: ByteStream?

    public init(
        method: Swift.String,
        requestUri: URL,
        headers: [Swift.String: Swift.String] = [:],
        content: ByteStream? = nil
    ) {
        self.method = method
        self.requestUri = requestUri
        self.headers = headers
        self.content = content
    }
}

extension RequestMessage: CustomStringConvertible {
    public var description: String {
        """
        request\n\
        method: \(method)\n\
        url: \(requestUri)\n\
        header: \(headers.map {
            "\($0.key): \($0.value)"
        }.joined(separator: "\n\t\t"))
        """
    }
}
