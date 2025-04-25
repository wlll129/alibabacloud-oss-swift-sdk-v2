import AlibabaCloudOSS
import Foundation
import XMLCoder

// MARK: - PutBucketTags

extension Serde {
    static func serializePutBucketTags(
        _ request: inout PutBucketTagsRequest,
        _ input: inout OperationInput
    ) throws {
        let data: Data = try XMLEncoder().encode(request.tagging, withRootKey: "Tagging")
        input.body = .data(data)
    }

    static func deserializePutBucketTags(
        _: inout PutBucketTagsResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetBucketTags

extension Serde {
    static func serializeGetBucketTags(
        _: inout GetBucketTagsRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeGetBucketTags(
        _ result: inout GetBucketTagsResult,
        _ output: inout OperationOutput
    ) throws {
        guard let data = try output.body?.readData() else {
            throw ClientError.parseResponseBodyError(info: "Can not get response body.")
        }
        let tagging = try XMLDecoder().decode(Tagging.self, from: data)
        result.tagging = tagging
    }
}

// MARK: - DeleteBucketTags

extension Serde {
    static func serializeDeleteBucketTags(
        _: inout DeleteBucketTagsRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeDeleteBucketTags(
        _: inout DeleteBucketTagsResult,
        _: inout OperationOutput
    ) throws {}
}
