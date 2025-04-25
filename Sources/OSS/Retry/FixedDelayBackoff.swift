
import Foundation

public struct FixedDelayBackoff: Backoff {
    let fixedBackoff: TimeInterval

    public func backoffDelay(attempt _: Int, error _: Error) -> TimeInterval {
        return fixedBackoff
    }
}
