import Foundation

/// The request for the PutBucketAcl operation.
public struct PutBucketAclRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    /// The ACL that you want to configure or modify for the bucket. The x-oss-acl header is included in PutBucketAcl requests to configure or modify the ACL of the bucket. If this header is not included, the ACL configurations do not take effect.
    /// Valid values:
    ///    public-read-write: All users can read and write objects in the bucket. Exercise caution when you set the value to public-read-write.
    ///    public-read: Only the owner and authorized users of the bucket can read and write objects in the bucket. Other users can only read objects in the bucket. Exercise caution when you set the value to public-read.
    ///    private: Only the owner and authorized users of this bucket can read and write objects in the bucket. Other users cannot access objects in the bucket.
    /// Sees BucketACLType for supported values.
    public var acl: Swift.String?

    public init(
        bucket: Swift.String? = nil,
        acl: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.acl = acl
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the PutBucketAcl operation.
public struct PutBucketAclResult: ResultModel {
    public var commonProp: ResultModelProp = .init()
}

/// The request for the GetBucketAcl operation.
public struct GetBucketAclRequest: RequestModel {
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

/// The result for the GetBucketAcl operation.
public struct GetBucketAclResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// The container that stores the ACL information.
    public var accessControlPolicy: AccessControlPolicy?
}
