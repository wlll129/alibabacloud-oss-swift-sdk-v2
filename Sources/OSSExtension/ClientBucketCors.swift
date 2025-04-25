import AlibabaCloudOSS
import Foundation

public extension Client {
    /// Configures cross-origin resource sharing (CORS) rules for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putBucketCors(
        _ request: PutBucketCorsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutBucketCorsResult {
        var input = OperationInput(
            operationName: "PutBucketCors",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "cors": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        try request.corsConfiguration.ensureRequired(field: "request.corsConfiguration")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializePutBucketCors, Serde.addContentMd5])
        var output = try await invokeOperation(input, options)

        var result = PutBucketCorsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutBucketCors])

        return result
    }

    /// Queries the cross-origin resource sharing (CORS) rules that are configured for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketCors(
        _ request: GetBucketCorsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketCorsResult {
        var input = OperationInput(
            operationName: "GetBucketCors",
            method: "GET",
            parameters: [
                "cors": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketCors, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = GetBucketCorsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketCors])

        return result
    }

    /// Disables the cross-origin resource sharing (CORS) feature and deletes all CORS rules for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func deleteBucketCors(
        _ request: DeleteBucketCorsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> DeleteBucketCorsResult {
        var input = OperationInput(
            operationName: "DeleteBucketCors",
            method: "DELETE",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "cors": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeDeleteBucketCors, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = DeleteBucketCorsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeDeleteBucketCors])

        return result
    }

    /// Determines whether to send a cross-origin request. Before a cross-origin request is sent, the browser sends a preflight OPTIONS request that includes a specific origin, HTTP method, and header information to Object Storage Service (OSS) to determine whether to send the cross-origin request.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func optionObject(
        _ request: OptionObjectRequest,
        _ options: OperationOptions? = nil
    ) async throws -> OptionObjectResult {
        var input = OperationInput(
            operationName: "OptionObject",
            method: "OPTIONS",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.bucket.ensureRequired(field: "request.key")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeOptionObject, Serde.addContentMd5])

        var output = try await invokeOperation(input, options)

        var result = OptionObjectResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeOptionObject])

        return result
    }
}
