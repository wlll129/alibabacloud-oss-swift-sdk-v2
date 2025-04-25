import Foundation

public extension Client {
    /// Initiates a multipart upload task.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func initiateMultipartUpload(
        _ request: InitiateMultipartUploadRequest,
        _ options: OperationOptions? = nil
    ) async throws -> InitiateMultipartUploadResult {
        var input = OperationInput(
            operationName: "InitiateMultipartUpload",
            method: "POST",
            parameters: [
                "uploads": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")

        var req = request

        var customDeserializers: [SerdeSerializeDelegate] = [Serde.serializeInitiateMultipartUpload, Serde.addContentMd5]
        if clientImpl.hasFeatureFlag(FeatureFlag.autoDetectMimeType) {
            customDeserializers.append(Serde.addContentType)
        } else {
            // urlsession add Content-Type:application/x-www-form-urlencoded default
            if req.contentType == nil {
                req.contentType = "application/octet-stream"
            }
        }

        try Serde.serializeInput(&req, &input, customDeserializers)

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = InitiateMultipartUploadResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeInitiateMultipartUpload])

        return result
    }

    /// You can call this operation to upload an object by part based on the object name and the upload ID that you specify.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func uploadPart(
        _ request: UploadPartRequest,
        _ options: OperationOptions? = nil
    ) async throws -> UploadPartResult {
        var input = OperationInput(
            operationName: "UploadPart",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        try request.uploadId.ensureRequired(field: "request.uploadId")
        try request.partNumber.ensureRequired(field: "request.partNumber")
        if let progress = request.progress {
            input.metadata.set(
                key: AttributeKeys.progressDelegate,
                value: ProgressDelegateDesc(delegate: ProgressWithRetry(progress), upload: true)
            )
        }
        if clientImpl.hasFeatureFlag(FeatureFlag.enableCRC64CheckUpload) {
            input.metadata.append(
                key: AttributeKeys.responseHandler,
                value: ChekerUploadCrcResponseHandler()
            )
        }

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeUploadPart, Serde.addContentMd5, Serde.addContentType])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = UploadPartResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeUploadPart])

        return result
    }

    /// You can call this operation to complete the multipart upload task of an object.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func completeMultipartUpload(
        _ request: CompleteMultipartUploadRequest,
        _ options: OperationOptions? = nil
    ) async throws -> CompleteMultipartUploadResult {
        var input = OperationInput(
            operationName: "CompleteMultipartUpload",
            method: "POST",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        try request.uploadId.ensureRequired(field: "request.uploadId")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeCompleteMultipartUpload, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = CompleteMultipartUploadResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeCompleteMultipartUpload])

        return result
    }

    /// 通过拷贝现有文件的方式上传单个分片
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func uploadPartCopy(
        _ request: UploadPartCopyRequest,
        _ options: OperationOptions? = nil
    ) async throws -> UploadPartCopyResult {
        var input = OperationInput(
            operationName: "UploadPartCopy",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        try request.uploadId.ensureRequired(field: "request.uploadId")
        try request.partNumber.ensureRequired(field: "request.partNumber")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeUploadPartCopy, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = UploadPartCopyResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeUploadPartCopy])

        return result
    }

    /// You can call this operation to cancel a multipart upload task and delete the parts that are uploaded by the multipart upload task.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func abortMultipartUpload(
        _ request: AbortMultipartUploadRequest,
        _ options: OperationOptions? = nil
    ) async throws -> AbortMultipartUploadResult {
        var input = OperationInput(
            operationName: "AbortMultipartUpload",
            method: "DELETE",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        try request.uploadId.ensureRequired(field: "request.uploadId")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeAbortMultipartUpload, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = AbortMultipartUploadResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeAbortMultipartUpload])

        return result
    }

    /// You can call this operation to list all ongoing multipart upload tasks.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listMultipartUploads(
        _ request: ListMultipartUploadsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> ListMultipartUploadsResult {
        var input = OperationInput(
            operationName: "ListMultipartUploads",
            method: "GET",
            parameters: [
                "uploads": "",
                "encoding-type": "url",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        
        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeListMultipartUploads, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListMultipartUploadsResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListMultipartUploads])

        return result
    }

    /// You can call this operation to list all parts that are uploaded by using a specified upload ID.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listParts(
        _ request: ListPartsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> ListPartsResult {
        var input = OperationInput(
            operationName: "ListParts",
            method: "GET",
            parameters: [
                "encoding-type": "url",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")
        input.key = try request.key.ensureRequired(field: "request.key")
        try request.uploadId.ensureRequired(field: "request.uploadId")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeListParts, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListPartsResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListParts])

        return result
    }
}
