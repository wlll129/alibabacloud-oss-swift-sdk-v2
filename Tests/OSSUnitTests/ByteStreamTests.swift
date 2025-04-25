@testable import AlibabaCloudOSS
import Foundation
import XCTest

class ByteStreamTests: XCTestCase {
    func testIsSeekable() {
        var b = ByteStream.none
        XCTAssertTrue(b.isSeekable)

        b = ByteStream.data(Data())
        XCTAssertTrue(b.isSeekable)

        b = ByteStream.file(URL(fileURLWithPath: "/tmp/test.txt"))
        XCTAssertTrue(b.isSeekable)

        b = ByteStream.stream(InputStream(data: Data()))
        XCTAssertFalse(b.isSeekable)
    }

    func testReadDataAndGetBodyLength() throws {
        var b = ByteStream.none
        var got = try b.readData()
        var len = try b.getBodyLength()
        XCTAssertNil(got)
        XCTAssertEqual(0, len)

        var data = "hello oss".data(using: .utf8)!
        b = ByteStream.data(data)
        got = try b.readData()
        len = try b.getBodyLength()
        XCTAssertEqual(data, got)
        XCTAssertEqual(9, len)

        data = "hello oss 1".data(using: .utf8)!
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: false)
        // not exist
        b = ByteStream.file(url)
        do {
            got = try b.readData()
            XCTFail("shoud not reach here")
        } catch {
            XCTAssertNotNil(error)
        }
        do {
            len = try b.getBodyLength()
            XCTFail("shoud not reach here")
        } catch {
            XCTAssertNotNil(error)
        }

        // exist
        _ = FileManager.default.createFile(atPath: url.path, contents: data)
        defer { _ = try? FileManager.default.removeItem(at: url) }

        b = ByteStream.file(url)
        got = try b.readData()
        len = try b.getBodyLength()
        XCTAssertEqual(data, got)
        XCTAssertEqual(11, len)

        b = ByteStream.stream(InputStream(data: data))
        do {
            len = try b.getBodyLength()
            XCTAssertNil(len)
            got = try b.readData()
            XCTFail("shoud not reach here")
        } catch {
            XCTAssertTrue("\(error)".contains("streamForBodyNotSuportedRead"))
        }
    }

    func testHashcrc64() throws {
        // none
        let none = ByteStream.none
        XCTAssertEqual(0, none.hashCrc64ecma())

        // data
        let b = ByteStream.data("123456789".data(using: .utf8)!)
        XCTAssertEqual(0x995D_C9BB_DF19_39FA, b.hashCrc64ecma())

        let b1 = ByteStream.data("987654321".data(using: .utf8)!)
        XCTAssertEqual(0xE7AD_EF3D_663C_7E22, b1.hashCrc64ecma())

        // file
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: false)
        _ = FileManager.default.createFile(atPath: url.path, contents: "123456789".data(using: .utf8)!)
        defer { _ = try? FileManager.default.removeItem(at: url) }
        let file = ByteStream.file(url)
        XCTAssertEqual(0x995D_C9BB_DF19_39FA, file.hashCrc64ecma())

        // stream
        let stream = ByteStream.stream(InputStream(data: "123456789".data(using: .utf8)!))
        XCTAssertNil(stream.hashCrc64ecma())
    }
}
