import Foundation

public extension Client {
    /// You can call this operation to add tags to or modify the tags of an object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putObjectTagging(
        _ request: PutObjectTaggingRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutObjectTaggingResult {
        var input = OperationInput(
            operationName: "PutObjectTagging",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializePutObjectTagging, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutObjectTaggingResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutObjectTagging])

        return result
    }

    /// You can call this operation to query the tags of an object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getObjectTagging(
        _ request: GetObjectTaggingRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetObjectTaggingResult {
        var input = OperationInput(
            operationName: "GetObjectTagging",
            method: "GET",
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetObjectTagging, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetObjectTaggingResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectTagging])

        return result
    }

    /// You can call this operation to delete the tags of a specified object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func deleteObjectTagging(
        _ request: DeleteObjectTaggingRequest,
        _ options: OperationOptions? = nil
    ) async throws -> DeleteObjectTaggingResult {
        var input = OperationInput(
            operationName: "DeleteObjectTagging",
            method: "DELETE",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "tagging": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeDeleteObjectTagging, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = DeleteObjectTaggingResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeDeleteObjectTagging])

        return result
    }
}
