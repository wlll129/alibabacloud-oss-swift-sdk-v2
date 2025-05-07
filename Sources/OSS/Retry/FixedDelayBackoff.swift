
import Foundation

public struct FixedDelayBackoff: Backoff {
    let fixedBackoff: TimeInterval
    
    public init(fixedBackoff: TimeInterval) {
        self.fixedBackoff = fixedBackoff
    }

    public func backoffDelay(attempt _: Int, error _: Error) -> TimeInterval {
        return fixedBackoff
    }
}
