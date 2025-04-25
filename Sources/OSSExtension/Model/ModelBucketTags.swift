import AlibabaCloudOSS
import Foundation

/// The request for the PutBucketTags operation.
public struct PutBucketTagsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    /// The request body schema.
    public var tagging: Tagging?

    public init(
        bucket: Swift.String? = nil,
        tagging: Tagging? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.tagging = tagging
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the PutBucketTags operation.
public struct PutBucketTagsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()
}

/// The request for the GetBucketTags operation.
public struct GetBucketTagsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    public init(
        bucket: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the GetBucketTags operation.
public struct GetBucketTagsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// The container that stores the returned tags of the bucket. If no tags are configured for the bucket, an XML message body is returned in which the Tagging element is empty.
    public var tagging: Tagging?
}

/// The request for the DeleteBucketTags operation.
public struct DeleteBucketTagsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    public init(
        bucket: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the DeleteBucketTags operation.
public struct DeleteBucketTagsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()
}
