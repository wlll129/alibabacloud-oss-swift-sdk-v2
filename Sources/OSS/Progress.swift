
public protocol ProgressDelegate: Sendable {
    mutating func onProgress(_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64)
}

public struct ProgressClosure: ProgressDelegate {
    private let closure: @Sendable (_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64) -> Void

    public init(closure: @Sendable @escaping (_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64) -> Void) {
        self.closure = closure
    }

    public func onProgress(_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64) {
        closure(bytesIncrement, totalBytesTransferred, totalBytesExpected)
    }
}

struct ProgressWithRetry: ProgressDelegate {
    private var delegate: ProgressDelegate
    private var ltotalBytesTransferred: Int64

    public init(_ delegate: ProgressDelegate) {
        self.delegate = delegate
        self.ltotalBytesTransferred = 0
    }

    public mutating func onProgress(_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64) {
        if totalBytesTransferred > ltotalBytesTransferred {
            self.delegate.onProgress(bytesIncrement, totalBytesTransferred, totalBytesExpected)
            ltotalBytesTransferred = totalBytesTransferred
        }
    }
}

public struct ProgressDelegateDesc: Sendable {
    public private(set) var delegate: ProgressDelegate
    public let upload: Bool

    public init(delegate: ProgressDelegate, upload: Bool) {
        self.delegate = delegate
        self.upload = upload
    }
}

public extension AttributeKeys {
    static let progressDelegate = AttributeKey<ProgressDelegateDesc>(name: "progress-delegate")
}
