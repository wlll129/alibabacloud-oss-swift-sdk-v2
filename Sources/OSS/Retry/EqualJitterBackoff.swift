import Foundation

public struct EqualJitterBackoff: Backoff {
    let baseDelay: TimeInterval
    let maxBackoff: TimeInterval
    
    public init(baseDelay: TimeInterval, maxBackoff: TimeInterval) {
        self.baseDelay = baseDelay
        self.maxBackoff = maxBackoff
    }

    public func backoffDelay(attempt: Int, error _: Error) -> TimeInterval {
        let ceil = min(pow(Double(2), Double(attempt) * baseDelay), maxBackoff)
        let delay = Double(ceil / 2) + Double.random(in: 0 ..< 1) * Double(ceil / 2 + 1)

        return delay
    }
}
