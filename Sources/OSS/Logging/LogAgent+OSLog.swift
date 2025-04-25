import Foundation
#if canImport(os)
    import os

    public struct LogAgentOSLog: LogAgent {
        private let logger = OSLog(subsystem: SdkInfo.sdkName, category: "main")

        let level: LogAgentLevel

        public init(level: LogAgentLevel) {
            self.level = level
        }

        public var name: String { return "OSLog" }

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
                let type: OSLogType = .from(loggerLevel: level)
                os_log("%{public}@", log: logger, type: type, message)
            }
        }
    }

    extension OSLogType {
        static func from(loggerLevel: LogAgentLevel) -> Self {
            switch loggerLevel {
            case .trace:
                /// `OSLog` doesn't have `trace`, so use `debug`
                return .debug
            case .debug:
                return .debug
            case .info:
                return .info
            case .warn:
                /// `OSLog` doesn't have `warning`, so use `info`
                return .info
            case .error:
                return .error
            }
        }
    }
#endif
