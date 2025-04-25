
@testable import AlibabaCloudOSS
import XCTest

class MimeUtilsTests: XCTestCase {
    func testGetMimiType() {
        let filePath1 = "/dir/dir/file.png"
        let filePath2 = "/dir/file"
        let filePath3 = "/dir/dir/"

        var mimiType = MimeUtils.getMimeType(fileURL: URL(fileURLWithPath: filePath1))
        XCTAssertEqual(mimiType, "image/png")

        mimiType = MimeUtils.getMimeType(fileURL: URL(fileURLWithPath: filePath2))
        XCTAssertNil(mimiType)

        mimiType = MimeUtils.getMimeType(fileURL: URL(fileURLWithPath: filePath3))
        XCTAssertNil(mimiType)

        let fileName1 = "file.png"
        let fileName2 = "file"
        let fileName3 = "file."
        let fileName4 = "file/"
        let fileName5 = "file\\"
        let fileName6 = "file:"

        mimiType = MimeUtils.getMimeType(fileName: fileName1)
        XCTAssertEqual(mimiType, "image/png")

        mimiType = MimeUtils.getMimeType(fileName: fileName2)
        XCTAssertNil(mimiType)

        mimiType = MimeUtils.getMimeType(fileName: fileName3)
        XCTAssertNil(mimiType)

        mimiType = MimeUtils.getMimeType(fileName: fileName4)
        XCTAssertNil(mimiType)

        mimiType = MimeUtils.getMimeType(fileName: fileName5)
        XCTAssertNil(mimiType)

        mimiType = MimeUtils.getMimeType(fileName: fileName6)
        XCTAssertNil(mimiType)
    }
}
