import Foundation

public struct NopRetryer: Retryer {
    
    public init() { }
    
    public func maxAttempts() -> Int {
        return 1
    }

    public func isErrorRetryable(error _: Error) -> Bool {
        return false
    }

    public func retryDelay(attempt _: Int, error _: Error) -> TimeInterval {
        return TimeInterval(0)
    }
}
