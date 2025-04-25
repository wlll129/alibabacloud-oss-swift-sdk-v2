import Foundation

public struct OperationOptions {
    public var retryMaxAttempts: Swift.Int?

    public var readWriteTimeout: TimeInterval?

    /// internal use only
    /// use URLSession.download(for ..., delegate: ...) async throws -> (URL, URLResponse)
    var saveToURL: Bool

    public init(
        retryMaxAttempts: Swift.Int? = nil,
        readWriteTimeout: TimeInterval? = nil
    ) {
        self.retryMaxAttempts = retryMaxAttempts
        self.readWriteTimeout = readWriteTimeout
        saveToURL = false
    }
}
