
import AlibabaCloudOSS
import Crypto
import Foundation
import XCTest

struct IntegrationTestError: Error {
    var message: String
    init(_ message: String) {
        self.message = message
    }
}

open class Utils {
    public static func calculateMd5(fileURL url: URL) throws -> Data {
        let chunkSize = 8 * 1024
        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer {
                fileHandle.closeFile()
            }

            var md5 = Insecure.MD5()
            var done = false
            while !done {
                let data = fileHandle.readData(ofLength: chunkSize)
                if data.count == 0 {
                    done = true
                }
                md5.update(data: data)
            }

            return Data(md5.finalize())
        } catch {
            throw IntegrationTestError("Cannot open file: \(error.localizedDescription)")
        }
    }
}

actor ValueActor<T: Sendable> {
    private var value: T

    init(value: T) {
        self.value = value
    }

    func setValue(value: T) {
        self.value = value
    }

    func getValue() -> T {
        return value
    }
}

extension Data {
    func toBase64String() -> String {
        return base64EncodedString(options: .lineLength64Characters)
    }
}

extension Data {
    func calculateMd5() -> Data {
        Data(Insecure.MD5.hash(data: self))
    }
}

class ProgressDelegateTestImp: ProgressDelegate, @unchecked Sendable {
    var totalBytesTransferred: Int64
    let totalBytesExpected: Int64
    
    init(
        totalBytesTransferred: Int64 = 0,
        totalBytesExpected: Int64
    ) {
        self.totalBytesTransferred = totalBytesTransferred
        self.totalBytesExpected = totalBytesExpected
    }
    
    func onProgress(_ bytesIncrement: Int64, _ totalBytesTransferred: Int64, _ totalBytesExpected: Int64) {
        self.totalBytesTransferred += bytesIncrement
        XCTAssertEqual(self.totalBytesTransferred, totalBytesTransferred)
        XCTAssertEqual(totalBytesExpected, totalBytesExpected)
    }
}
