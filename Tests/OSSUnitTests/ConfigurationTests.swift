import AlibabaCloudOSS
import XCTest

final class ConfigurationTests: XCTestCase {
    func testConfigurationConstructor() throws {
        let config = Configuration.default()
        XCTAssertNotNil(config)
        XCTAssertNil(config.endpoint)
        XCTAssertNil(config.credentialsProvider)
    }

    func testConfigurationWithFunc() throws {
        let config = Configuration.default()
        XCTAssertNotNil(config)
        XCTAssertNil(config.endpoint)
        XCTAssertNil(config.credentialsProvider)

        config.withRegion("cn-hangzhou")
            .withCredentialsProvider(AnonymousCredentialsProvider())
            .withEndpoint("http://oss-cn-hangzhou.aliyuncs.com")

        XCTAssertEqual("http://oss-cn-hangzhou.aliyuncs.com", config.endpoint)
        XCTAssertEqual("cn-hangzhou", config.region)
        XCTAssertNotNil(config.credentialsProvider)
    }
}
