
@testable import AlibabaCloudOSS
import XCTest

class SerdeRegionTests: XCTestCase {
    func testSerializeDescribeRegions() throws {
        var input = OperationInput()
        var request = DescribeRegionsRequest()
        try Serde.serializeInput(&request, &input, [Serde.serializeDescribeRegions])
        XCTAssertNil(input.parameters["regions"] as Any?)

        request = DescribeRegionsRequest()
        request.regions = "regions"
        try Serde.serializeInput(&request, &input, [Serde.serializeDescribeRegions])
        XCTAssertEqual(input.parameters["regions"], request.regions)
    }

    func testDeserializeDescribeRegions() throws {
        // body is null
        var output = OperationOutput(statusCode: 200,
                                     headers: [:])
        var result = DescribeRegionsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeDescribeRegions]))

        // body is unexpected
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data("<a></a>".data(using: .utf8)!))
        result = DescribeRegionsResult()
        XCTAssertThrowsError(try Serde.deserializeOutput(&result, &output, [Serde.deserializeDescribeRegions]))

        // normal
        var regions = [RegionInfo(region: "region1", internetEndpoint: "internetEndpoint1", internalEndpoint: "internalEndpoint1", accelerateEndpoint: "accelerateEndpoint1"),
                       RegionInfo(region: "region2", internetEndpoint: "internetEndpoint2", internalEndpoint: "internalEndpoint2", accelerateEndpoint: "accelerateEndpoint2")]
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<RegionInfoList>")
        for region in regions {
            xml.append("<RegionInfo>")
            xml.append("<Region>\(region.region!)</Region>")
            xml.append("<InternetEndpoint>\(region.internetEndpoint!)</InternetEndpoint>")
            xml.append("<InternalEndpoint>\(region.internalEndpoint!)</InternalEndpoint>")
            xml.append("<AccelerateEndpoint>\(region.accelerateEndpoint!)</AccelerateEndpoint>")
            xml.append("</RegionInfo>")
        }
        xml.append("</RegionInfoList>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = DescribeRegionsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeDescribeRegions]))
        XCTAssertEqual(result.regionInfoList?.regionInfos?.count, regions.count)
        for region in regions {
            for resultRegion in result.regionInfoList!.regionInfos! {
                if region.region == resultRegion.region {
                    XCTAssertEqual(region.internalEndpoint, resultRegion.internalEndpoint)
                    XCTAssertEqual(region.internetEndpoint, resultRegion.internetEndpoint)
                    XCTAssertEqual(region.accelerateEndpoint, resultRegion.accelerateEndpoint)
                }
            }
        }

        regions = [RegionInfo(region: "region1", internetEndpoint: "internetEndpoint1", internalEndpoint: "internalEndpoint1", accelerateEndpoint: "accelerateEndpoint1")]
        xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xml.append("<RegionInfoList>")
        for region in regions {
            xml.append("<RegionInfo>")
            xml.append("<Region>\(region.region!)</Region>")
            xml.append("<InternetEndpoint>\(region.internetEndpoint!)</InternetEndpoint>")
            xml.append("<InternalEndpoint>\(region.internalEndpoint!)</InternalEndpoint>")
            xml.append("<AccelerateEndpoint>\(region.accelerateEndpoint!)</AccelerateEndpoint>")
            xml.append("</RegionInfo>")
        }
        xml.append("</RegionInfoList>")
        output = OperationOutput(statusCode: 200,
                                 headers: [:],
                                 body: .data(xml.data(using: .utf8)!))
        result = DescribeRegionsResult()
        XCTAssertNoThrow(try Serde.deserializeOutput(&result, &output, [Serde.deserializeDescribeRegions]))
        XCTAssertEqual(result.regionInfoList?.regionInfos?.count, regions.count)
        for region in regions {
            for resultRegion in result.regionInfoList!.regionInfos! {
                if region.region == resultRegion.region {
                    XCTAssertEqual(region.internalEndpoint, resultRegion.internalEndpoint)
                    XCTAssertEqual(region.internetEndpoint, resultRegion.internetEndpoint)
                    XCTAssertEqual(region.accelerateEndpoint, resultRegion.accelerateEndpoint)
                }
            }
        }
    }
}
