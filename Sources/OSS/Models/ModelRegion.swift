import Foundation

/// The information about the region.
public struct RegionInfo: Sendable {
    /// The region ID.
    public var region: Swift.String?

    /// The public endpoint of the region.
    public var internetEndpoint: Swift.String?

    /// The internal endpoint of the region.
    public var internalEndpoint: Swift.String?

    /// The acceleration endpoint of the region. The value is always oss-accelerate.aliyuncs.com.
    public var accelerateEndpoint: Swift.String?

    public init(
        region: Swift.String? = nil,
        internetEndpoint: Swift.String? = nil,
        internalEndpoint: Swift.String? = nil,
        accelerateEndpoint: Swift.String? = nil
    ) {
        self.region = region
        self.internetEndpoint = internetEndpoint
        self.internalEndpoint = internalEndpoint
        self.accelerateEndpoint = accelerateEndpoint
    }
}

/// The information about the regions.
public struct RegionInfoList: Sendable {
    /// The information about the regions.
    public var regionInfos: [RegionInfo]?

    public init(
        regionInfos: [RegionInfo]? = nil
    ) {
        self.regionInfos = regionInfos
    }
}

/// The request for the DescribeRegions operation.
public struct DescribeRegionsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The region ID of the request.
    public var regions: Swift.String?

    public init(
        regions: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.regions = regions
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the DescribeRegions operation.
public struct DescribeRegionsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// The information about the regions.
    public var regionInfoList: RegionInfoList?
}
