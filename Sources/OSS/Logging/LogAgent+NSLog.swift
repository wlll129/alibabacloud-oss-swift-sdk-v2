import Foundation

public struct LogAgentNSLog: LogAgent {
    let level: LogAgentLevel

    public init(level: LogAgentLevel) {
        self.level = level
    }

    public var name: String { return "NSLog" }

    public func log(
        level: LogAgentLevel,
        message: @autoclosure () -> String,
        metadata _: @autoclosure () -> [String: String]?,
        source _: @autoclosure () -> String,
        file _: String,
        function _: String,
        line _: UInt
    ) {
        if level >= self.level {
            let message = "[\(SdkInfo.sdkName)] \(level.rawValue) \(message())"
            NSLog("\(message)")
        }
    }
}
