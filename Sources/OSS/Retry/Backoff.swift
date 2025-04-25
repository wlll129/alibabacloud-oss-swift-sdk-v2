
import Foundation

public protocol Backoff {
    func backoffDelay(attempt: Int, error: Error) -> TimeInterval
}
