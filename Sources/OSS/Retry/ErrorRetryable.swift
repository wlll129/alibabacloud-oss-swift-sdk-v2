import Foundation

public protocol ErrorRetryable {
    func isErrorRetryable(error: Error) -> Bool
}
