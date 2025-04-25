import Foundation

public extension Client {
    /// Generates the pre-signed URL for GetObject operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: GetObjectRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "GetObject",
            method: "GET"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetObject])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for PutObject operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: PutObjectRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "PutObject",
            method: "PUT"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializePutObject])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for HeadObject operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: HeadObjectRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "HeadObject",
            method: "HEAD"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeHeadObject])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for InitiateMultipartUpload operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: InitiateMultipartUploadRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "InitiateMultipartUpload",
            method: "PUT",
            parameters: [
                "uploads": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeInitiateMultipartUpload])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for UploadPart operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: UploadPartRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "UploadPart",
            method: "PUT"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeUploadPart])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for CompleteMultipartUpload operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: CompleteMultipartUploadRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "CompleteMultipartUpload",
            method: "POST"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeCompleteMultipartUpload])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }

    /// Generates the pre-signed URL for AbortMultipartUpload operation.
    /// If you do not specify expiration, the pre-signed URL uses 15 minutes as default.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - expiration: Optional, The expiration time for the generated presign url.
    /// - Returns: The result instance.
    func presign(
        _ request: AbortMultipartUploadRequest,
        _ expiration: Foundation.Date? = nil
    ) async throws -> PresignResult {
        var input = OperationInput(
            operationName: "AbortMultipartUpload",
            method: "DELETE"
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        if let expiration = expiration {
            input.metadata.set(key: AttributeKeys.expirationTime, value: expiration)
        }

        var req = request
        try Serde.serializeInput(&req, &input, [Serde.serializeAbortMultipartUpload])

        let output = try await clientImpl.presignInner(with: &input)

        return PresignResult(
            method: output.method ?? "",
            url: output.url ?? "",
            expiration: output.expiration,
            signedHeaders: output.signedHeaders
        )
    }
}
