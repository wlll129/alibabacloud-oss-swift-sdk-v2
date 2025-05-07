import Foundation

public struct FullJitterBackoff: Backoff {
    let baseDelay: TimeInterval
    let maxBackoff: TimeInterval
    
    public init(baseDelay: TimeInterval, maxBackoff: TimeInterval) {
        self.baseDelay = baseDelay
        self.maxBackoff = maxBackoff
    }

    public func backoffDelay(attempt: Int, error _: Error) -> TimeInterval {
        let delay = Double.random(in: 0 ..< 1) * min(pow(Double(2), Double(attempt) * baseDelay), maxBackoff)

        return delay
    }
}
