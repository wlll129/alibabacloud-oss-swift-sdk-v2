/// The level for LogAgent.
///
/// Log levels are ordered by their severity, with `.trace` being the least severe and
/// `.error` being the most severe.
public enum LogAgentLevel: String, Codable, CaseIterable, Sendable {
    /// Appropriate for messages that contain information normally of use only when
    /// tracing the execution of a program.
    case trace

    /// Appropriate for messages that contain information normally of use only when
    /// debugging a program.
    case debug

    /// Appropriate for informational messages.
    case info

    /// Appropriate for messages that are not error conditions
    case warn

    /// Appropriate for error conditions.
    case error
}

extension LogAgentLevel {
    var naturalIntegralValue: Int {
        switch self {
        case .trace:
            return 0
        case .debug:
            return 1
        case .info:
            return 2
        case .warn:
            return 3
        case .error:
            return 4
        }
    }
}

extension LogAgentLevel: Comparable {
    public static func < (lhs: LogAgentLevel, rhs: LogAgentLevel) -> Bool {
        lhs.naturalIntegralValue < rhs.naturalIntegralValue
    }
}
