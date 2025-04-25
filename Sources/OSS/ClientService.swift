import Foundation

public extension Client {
    /// Queries all buckets that are owned by a requester.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listBuckets(
        _ request: ListBucketsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> ListBucketsResult {
        var input = OperationInput(
            operationName: "ListBuckets",
            method: "GET"
        )

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeListBuckets, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListBucketsResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListBuckets])

        return result
    }
}
