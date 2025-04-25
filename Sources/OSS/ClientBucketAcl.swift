import Foundation

public extension Client {
    /// Configures or modifies the access control list (ACL) for a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putBucketAcl(
        _ request: PutBucketAclRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutBucketAclResult {
        var input = OperationInput(
            operationName: "PutBucketAcl",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ],
            parameters: [
                "acl": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializePutBucketAcl, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutBucketAclResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutBucketAcl])

        return result
    }

    /// Queries the access control list (ACL) of a bucket. Only the owner of a bucket can query the ACL of the bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketAcl(
        _ request: GetBucketAclRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketAclResult {
        var input = OperationInput(
            operationName: "GetBucketAcl",
            method: "GET",
            parameters: [
                "acl": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketAcl, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetBucketAclResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketAcl])

        return result
    }
}
