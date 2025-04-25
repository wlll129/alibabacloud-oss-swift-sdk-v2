@testable import AlibabaCloudOSS
import XCTest

final class ClientTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClientConstructor() throws {
        let credentialsProvider = AnonymousCredentialsProvider()
        let endpoint = "oss-cn-hangzhou.aliyuncs.com"
        let config = Configuration.default()
            .withEndpoint(endpoint)
            .withCredentialsProvider(credentialsProvider)
        var client = Client(config)
        XCTAssertNotNil(client)

        // XCTAssertEqual("oss-cn-hangzhou.aliyuncs.com", client.options.endpoint)
        XCTAssertEqual("", client.clientImpl.options.region)

        client = Client(config) { $0.region = "cn-hangzhou" }
        // XCTAssertEqual("oss-cn-hangzhou.aliyuncs.com", client.options.endpoint)
        XCTAssertEqual("cn-hangzhou", client.clientImpl.options.region)

        client = Client(
            config,
            { $0.region = "cn-hangzhou" },
            // { $0.endpoint = "oss-cn-beijing.aliyuncs.com" },
            { $0.region = "cn-beijing" }
        )
        // XCTAssertEqual("oss-cn-beijing.aliyuncs.com", client.options.endpoint)
        XCTAssertEqual("cn-beijing", client.clientImpl.options.region)
    }

    func testClientFeatureFlags() throws {
        let credentialsProvider = AnonymousCredentialsProvider()
        let endpoint = "oss-cn-hangzhou.aliyuncs.com"
        let config = Configuration.default()
            .withEndpoint(endpoint)
            .withCredentialsProvider(credentialsProvider)
        let client = Client(config)
        XCTAssertNotNil(client)

        XCTAssertEqual(29, client.clientImpl.options.featureFlags.rawValue)

        XCTAssertTrue(client.clientImpl.hasFeatureFlag(FeatureFlag.correctClockSkew))
        XCTAssertTrue(client.clientImpl.hasFeatureFlag(FeatureFlag.autoDetectMimeType))
        XCTAssertTrue(client.clientImpl.hasFeatureFlag(FeatureFlag.enableCRC64CheckDownload))
        XCTAssertTrue(client.clientImpl.hasFeatureFlag(FeatureFlag.enableCRC64CheckUpload))

        XCTAssertFalse(client.clientImpl.hasFeatureFlag(FeatureFlag.enableMD5))
    }
}
