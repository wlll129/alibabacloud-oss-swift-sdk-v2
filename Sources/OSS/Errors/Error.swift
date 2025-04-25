
/// Standard Error type returned by sdk.
public protocol SdkErrorType: Error, CustomStringConvertible {
    /// Gets the Error instance that caused the current exception.
    var innerError: Error? { get }
}
