import Foundation

// MARK: - DescribeRegions

extension Serde {
    static func serializeDescribeRegions(
        _ request: inout DescribeRegionsRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.regions {
            input.parameters["regions"] = value
        }
    }

    static func deserializeDescribeRegions(
        _ result: inout DescribeRegionsResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "RegionInfoList")

        var regions: [[String: Any]] = []
        if let contents = body["RegionInfo"] as? [[String: Any]] {
            regions.append(contentsOf: contents)
        } else if let content = body["RegionInfo"] as? [String: Any] {
            regions.append(content)
        }

        var regionInfos: [RegionInfo] = []
        for region in regions {
            var regionInfo = RegionInfo()
            regionInfo.region = region["Region"] as? String
            regionInfo.accelerateEndpoint = region["AccelerateEndpoint"] as? String
            regionInfo.internalEndpoint = region["InternalEndpoint"] as? String
            regionInfo.internetEndpoint = region["InternetEndpoint"] as? String
            regionInfos.append(regionInfo)
        }
        result.regionInfoList = RegionInfoList(regionInfos: regionInfos)
    }
}
