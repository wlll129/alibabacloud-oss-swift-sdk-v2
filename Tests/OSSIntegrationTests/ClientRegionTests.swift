import AlibabaCloudOSS
import XCTest

class ClientRegionTests: BaseTestCase {
    func testDescribeRegionsSuccess() async throws {
        let client = getDefaultClient()
        let region = "oss-cn-hangzhou"

        let request = DescribeRegionsRequest(regions: region)
        let result = try await client.describeRegions(request)
        XCTAssertEqual(result.statusCode, 200)
        XCTAssertEqual(result.regionInfoList?.regionInfos?.count, 1)
        XCTAssertEqual(result.regionInfoList?.regionInfos?.first?.internalEndpoint, "\(region)-internal.aliyuncs.com")
        XCTAssertEqual(result.regionInfoList?.regionInfos?.first?.internetEndpoint, "\(region).aliyuncs.com")
        XCTAssertEqual(result.regionInfoList?.regionInfos?.first?.accelerateEndpoint, "oss-accelerate.aliyuncs.com")
        XCTAssertEqual(result.regionInfoList?.regionInfos?.first?.region, region)
    }

    func testDescribeRegionsFail() async throws {
        let client = getDefaultClient()
        let region = "cn-hangzhou"

        let request = DescribeRegionsRequest(regions: region)
        try await assertThrowsAsyncError(await client.describeRegions(request)) {
            let serverError = $0 as? ServerError
            XCTAssertEqual(serverError?.statusCode, 404)
            XCTAssertEqual(serverError?.code, "NoSuchRegion")
            XCTAssertEqual(serverError?.message, "cn-hangzhou")
        }
    }
}
