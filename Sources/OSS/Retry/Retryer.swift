import Foundation

public protocol Retryer {
    func isErrorRetryable(error: Error) -> Bool

    func maxAttempts() -> Int

    func retryDelay(attempt: Int, error: Error) -> TimeInterval
}
