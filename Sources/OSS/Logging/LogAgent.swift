
public protocol LogAgent: Sendable {
    /// name of the struct or class where the logger was instantiated from
    var name: String { get }

    /// Log a message passing the log level as a parameter.
    ///
    /// If the ``LogAgentLevel`` passed to this method is more severe than the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - level: The log level to log `message` at. For the available log levels, see `LogAgentLevel`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message.
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID`.
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    func log(level: LogAgentLevel,
             message: @autoclosure () -> String,
             metadata: @autoclosure () -> [String: String]?,
             source: @autoclosure () -> String,
             file: String,
             function: String,
             line: UInt)
}

/// Convenience wrapper functions that call `self.log()` with corresponding log level.
public extension LogAgent {
    /// Use for messages that are typically seen during trace.
    func trace(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .trace,
            message: message(),
            metadata: nil,
            source: currentModule(fileID: file),
            file: file,
            function: function,
            line: line)
    }

    /// Use for messages that are typically seen during debugging.
    func debug(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug,
            message: message(),
            metadata: nil,
            source: currentModule(fileID: file),
            file: file,
            function: function,
            line: line)
    }

    /// Use for informational messages.
    func info(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .info,
            message: message(),
            metadata: nil,
            source: currentModule(fileID: file),
            file: file,
            function: function,
            line: line)
    }

    /// Use for non-error messages that are more severe than `.notice`.
    func warn(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .warn,
            message: message(),
            metadata: nil,
            source: currentModule(fileID: file),
            file: file,
            function: function,
            line: line)
    }

    /// Use for errors.
    func error(
        _ message: @autoclosure () -> String,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error,
            message: message(),
            metadata: nil,
            source: currentModule(fileID: file),
            file: file,
            function: function,
            line: line)
    }
}

private func currentModule(fileID: String = #fileID) -> String {
    let utf8All = fileID.utf8
    if let slashIndex = utf8All.firstIndex(of: UInt8(ascii: "/")) {
        return String(fileID[..<slashIndex])
    } else {
        return "n/a"
    }
}
