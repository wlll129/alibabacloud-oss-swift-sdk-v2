import Foundation

public extension Client {
    /// Queries the storage capacity of a bucket and the number of objects that are stored in the bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketStat(
        _ request: GetBucketStatRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketStatResult {
        var input = OperationInput(
            operationName: "GetBucketStat",
            method: "GET",
            parameters: [
                "stat": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketStat, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetBucketStatResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketStat])

        return result
    }

    /// Creates a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func putBucket(
        _ request: PutBucketRequest,
        _ options: OperationOptions? = nil
    ) async throws -> PutBucketResult {
        var input = OperationInput(
            operationName: "PutBucket",
            method: "PUT",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializePutBucket, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = PutBucketResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializePutBucket])

        return result
    }

    /// Deletes a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func deleteBucket(
        _ request: DeleteBucketRequest,
        _ options: OperationOptions? = nil
    ) async throws -> DeleteBucketResult {
        var input = OperationInput(
            operationName: "DeleteBucket",
            method: "DELETE",
            headers: [
                "Content-Type": "application/xml",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeDeleteBucket, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = DeleteBucketResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeDeleteBucket])

        return result
    }

    /// Queries the information about all objects in a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listObjects(
        _ request: ListObjectsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> ListObjectsResult {
        var input = OperationInput(
            operationName: "ListObjects",
            method: "GET",
            parameters: [
                "encoding-type": "url",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeListObjects, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListObjectsResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjects])

        return result
    }

    /// Queries the information about all objects in a bucket.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func listObjectsV2(
        _ request: ListObjectsV2Request,
        _ options: OperationOptions? = nil
    ) async throws -> ListObjectsV2Result {
        var input = OperationInput(
            operationName: "ListObjectsV2",
            method: "GET",
            parameters: [
                "list-type": "2",
                "encoding-type": "url",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeListObjectsV2, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = ListObjectsV2Result()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeListObjectsV2])

        return result
    }

    /// Queries the information about a bucket. Only the owner of a bucket can query the information about the bucket. You can call this operation from an Object Storage Service (OSS) endpoint.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketInfo(
        _ request: GetBucketInfoRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketInfoResult {
        var input = OperationInput(
            operationName: "GetBucketInfo",
            method: "GET",
            parameters: [
                "bucketInfo": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketInfo, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetBucketInfoResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketInfo])

        return result
    }

    /// Queries the region in which a bucket resides. Only the owner of a bucket can query the region in which the bucket resides.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func getBucketLocation(
        _ request: GetBucketLocationRequest,
        _ options: OperationOptions? = nil
    ) async throws -> GetBucketLocationResult {
        var input = OperationInput(
            operationName: "GetBucketLocation",
            method: "GET",
            parameters: [
                "location": "",
            ]
        )
        input.bucket = try request.bucket.ensureRequired(field: "request.bucket")

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeGetBucketLocation, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = GetBucketLocationResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeGetBucketLocation])

        return result
    }
}
