@testable import AlibabaCloudOSS
import XCTest

class LogAgentTests: XCTestCase {
    
    func testLogAgent() {
        var logger = LogAgentTest(level: .trace)
        logger.trace("trace")
        logger.debug("debug")
        logger.info("info")
        logger.warn("warn")
        logger.error("error")
        var output =
        """
        [alibabacloud-swift-sdk-v2] trace trace AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 8\
        [alibabacloud-swift-sdk-v2] debug debug AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 9\
        [alibabacloud-swift-sdk-v2] info info AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 10\
        [alibabacloud-swift-sdk-v2] warn warn AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 11\
        [alibabacloud-swift-sdk-v2] error error AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 12
        """
        XCTAssertEqual(logger.data, output.data(using: .utf8))
        
        logger = LogAgentTest(level: .info)
        logger.trace("trace")
        logger.debug("debug")
        logger.info("info")
        logger.warn("warn")
        logger.error("error")
        output =
        """
        [alibabacloud-swift-sdk-v2] info info AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 26\
        [alibabacloud-swift-sdk-v2] warn warn AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 27\
        [alibabacloud-swift-sdk-v2] error error AlibabaCloudOSSUnitTests/LogAgentTests.swift AlibabaCloudOSSUnitTests testLogAgent() 28
        """
        XCTAssertEqual(logger.data, output.data(using: .utf8))
    }
}

final class LogAgentTest: LogAgent, @unchecked Sendable {
    let level: LogAgentLevel
    
    var data = Data()

    public init(level: LogAgentLevel) {
        self.level = level
    }

    public var name: String { return "NSLog" }

    public func log(
        level: LogAgentLevel,
        message: @autoclosure () -> String,
        metadata: @autoclosure () -> [String: String]?,
        source: @autoclosure () -> String,
        file: String,
        function: String,
        line: UInt
    ) {
        if level >= self.level {
            let message = "[\(SdkInfo.sdkName)] \(level.rawValue) \(message()) \(file) \(source()) \(function) \(line)"
            data.append(message.data(using: .utf8)!)
        }
    }
}
