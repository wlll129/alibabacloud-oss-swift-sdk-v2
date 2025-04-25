import Foundation

public extension Client {
    /// Configures the versioning state for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putBucketVersioning(
        _ request: PutBucketVersioningRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutBucketVersioningResult {
        var input = OperationInput(
            operationName: "PutBucketVersioning",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "versioning": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        try request.versioningConfiguration.ensureRequired(field: "request.versioningConfiguration")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializePutBucketVersioning, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutBucketVersioningResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutBucketVersioning])

        return result
    }

    /// Queries the versioning state of a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketVersioning(
        _ request: GetBucketVersioningRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketVersioningResult {
        var input = OperationInput(
            operationName: "GetBucketVersioning",
            method: "GET",
            parameters: [
                "versioning": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketVersioning, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetBucketVersioningResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketVersioning])

        return result
    }

    /// Queries the information about the versions of all objects in a bucket, including the delete markers.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listObjectVersions(
        _ request: ListObjectVersionsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> ListObjectVersionsResult {
        var input = OperationInput(
            operationName: "ListObjectVersions",
            method: "GET",
            parameters: [
                "versions": "",
                "encoding-type": "url",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeListObjectVersions, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListObjectVersionsResult()
        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjectVersions])

        return result
    }
}
