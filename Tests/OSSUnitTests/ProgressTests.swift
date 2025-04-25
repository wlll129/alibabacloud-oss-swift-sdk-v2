@testable import AlibabaCloudOSS
import XCTest

class ProgressTests: XCTestCase {
    func testProgressWithRetry() {
        nonisolated(unsafe) var ltotalBytesTransferred: Int64 = 0
        let progress = ProgressClosure { _, totalBytesTransferred, _ in
            XCTAssertLessThanOrEqual(ltotalBytesTransferred, totalBytesTransferred)
            ltotalBytesTransferred = totalBytesTransferred
        }

        var prog = ProgressWithRetry(progress)

        for bytesCount in stride(from: 0, through: 50, by: 5) {
            prog.onProgress(5, Int64(bytesCount), 100)
        }

        for bytesCount in stride(from: 0, through: 100, by: 5) {
            prog.onProgress(5, Int64(bytesCount), 100)
        }
    }
}
