import Foundation

struct NopRetryer: Retryer {
    func maxAttempts() -> Int {
        return 1
    }

    func isErrorRetryable(error _: Error) -> Bool {
        return false
    }

    func retryDelay(attempt _: Int, error _: Error) -> TimeInterval {
        return TimeInterval(0)
    }
}
