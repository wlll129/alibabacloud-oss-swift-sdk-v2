import AlibabaCloudOSS
import Foundation

public extension Client {
    /// Adds tags to or modifies the existing tags of a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putBucketTags(
        _ request: PutBucketTagsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutBucketTagsResult {
        var input = OperationInput(
            operationName: "PutBucketTags",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        try request.tagging.ensureRequired(field: "request.tagging")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializePutBucketTags, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = PutBucketTagsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutBucketTags])

        return result
    }

    /// Queries the tags of a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketTags(
        _ request: GetBucketTagsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketTagsResult {
        var input = OperationInput(
            operationName: "GetBucketTags",
            method: "GET",
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketTags, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = GetBucketTagsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketTags])

        return result
    }

    /// Deletes tags configured for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func deleteBucketTags(
        _ request: DeleteBucketTagsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> DeleteBucketTagsResult {
        var input = OperationInput(
            operationName: "DeleteBucketTags",
            method: "DELETE",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeDeleteBucketTags, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = DeleteBucketTagsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeDeleteBucketTags])

        return result
    }
}
