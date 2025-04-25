import Foundation

public extension Client {
    /// You can call this operation to modify the ACL of an object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putObjectAcl(
        _ request: PutObjectAclRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutObjectAclResult {
        var input = OperationInput(
            operationName: "PutObjectAcl",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "acl": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializePutObjectAcl, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutObjectAclResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutObjectAcl])

        return result
    }

    /// You can call this operation to query the ACL of an object in a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getObjectAcl(
        _ request: GetObjectAclRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetObjectAclResult {
        var input = OperationInput(
            operationName: "GetObjectAcl",
            method: "GET",
            parameters: [
                "acl": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetObjectAcl, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetObjectAclResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetObjectAcl])

        return result
    }
}
