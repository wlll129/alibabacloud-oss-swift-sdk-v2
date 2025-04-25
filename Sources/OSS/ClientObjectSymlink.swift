import Foundation

public extension Client {
    /// You can create a symbolic link for a target object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putSymlink(
        _ request: PutSymlinkRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutSymlinkResult {
        var input = OperationInput(
            operationName: "PutSymlink",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "symlink": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializePutSymlink, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutSymlinkResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutSymlink])

        return result
    }

    /// You can call this operation to query a symbolic link of an object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getSymlink(
        _ request: GetSymlinkRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetSymlinkResult {
        var input = OperationInput(
            operationName: "GetSymlink",
            method: "GET",
            parameters: [
                "symlink": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetSymlink, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetSymlinkResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetSymlink])

        return result
    }
}
