import Foundation

/// The container that stores the information about the bucket.
public struct BucketSummary: Sendable {
    /// The time when the bucket was created. Format: `yyyy-mm-ddThh:mm:ss.timezone`.
    public var creationDate: Foundation.Date?

    /// The public endpoint of the region in which the bucket resides.
    public var extranetEndpoint: Swift.String?

    /// The internal endpoint of the region in which the bucket you access from ECS instances resides. The bucket and ECS instances are in the same region.
    public var intranetEndpoint: Swift.String?

    /// The data center in which the bucket is located.
    public var location: Swift.String?

    /// The name of the bucket.
    public var name: Swift.String?

    /// The storage class of the bucket. Valid values: Standard, IA, Archive, and ColdArchive.
    /// Sees StorageClassType for supported values.
    public var storageClass: Swift.String?

    /// The region in which the bucket is located.
    public var region: Swift.String?

    public init(
        creationDate: Foundation.Date? = nil,
        extranetEndpoint: Swift.String? = nil,
        intranetEndpoint: Swift.String? = nil,
        location: Swift.String? = nil,
        name: Swift.String? = nil,
        storageClass: Swift.String? = nil,
        region: Swift.String? = nil
    ) {
        self.creationDate = creationDate
        self.extranetEndpoint = extranetEndpoint
        self.intranetEndpoint = intranetEndpoint
        self.location = location
        self.name = name
        self.storageClass = storageClass
        self.region = region
    }
}

/// The request for the ListBuckets operation.
public struct ListBucketsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The ID of the resource group to which the bucket belongs.
    public var resourceGroupId: Swift.String?

    /// The prefix that the names of returned buckets must contain. If this parameter is not specified, prefixes are not used to filter returned buckets. By default, this parameter is left empty.
    public var prefix: Swift.String?

    /// The name of the bucket from which the buckets start to return. The buckets whose names are alphabetically after the value of marker are returned. If this parameter is not specified, all results are returned. By default, this parameter is left empty.
    public var marker: Swift.String?

    /// The maximum number of buckets that can be returned. Valid values: 1 to 1000. Default value: 100
    public var maxKeys: Swift.Int?

    public init(
        resourceGroupId: Swift.String? = nil,
        prefix: Swift.String? = nil,
        marker: Swift.String? = nil,
        maxKeys: Swift.Int? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.resourceGroupId = resourceGroupId
        self.prefix = prefix
        self.marker = marker
        self.maxKeys = maxKeys
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the ListBuckets operation.
public struct ListBucketsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// The maximum number of buckets that can be returned.
    public var maxKeys: Swift.Int?

    /// Indicates whether all results are returned. Valid values:- true: All results are not returned in the response. - false: All results are returned in the response.
    public var isTruncated: Swift.Bool?

    /// The marker for the next ListBuckets (GetService) request. You can use the value of this parameter as the value of marker in the next ListBuckets (GetService) request to retrieve the unreturned results.
    public var nextMarker: Swift.String?

    /// The container that stores the information about multiple buckets.
    public var buckets: [BucketSummary]?

    /// The container that stores the information about the bucket owner.
    public var owner: Owner?

    /// The prefix contained in the names of returned buckets.
    public var prefix: Swift.String?

    /// The name of the bucket from which the buckets are returned.
    public var marker: Swift.String?
}
