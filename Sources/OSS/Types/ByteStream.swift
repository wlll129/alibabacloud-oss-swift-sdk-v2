import Foundation

public enum ByteStream: @unchecked Sendable {
    /// nil body
    case none
    /// from the provided `Data` value.
    case data(Data)
    /// Body data is read from the given file URL
    case file(URL)
    /// from the provided `InputStream`
    case stream(InputStream)
}

public extension ByteStream {
    internal enum _Error: Error {
        case fileForBodyNotFound
        case streamForBodyNotSuportedRead
    }

    // Static property for an empty ByteStream
    static var empty: ByteStream {
        .data(Data())
    }

    // Returns true if the byte stream is seekable
    var isSeekable: Bool {
        switch self {
        case .none, .data, .file:
            return true
        case .stream:
            return false
        }
    }

    /// - Returns: The body length, or `nil` for no body (e.g. `GET` request).
    func getBodyLength() throws -> UInt64? {
        switch self {
        case .none:
            return 0
        case let .data(d):
            return UInt64(d.count)
        /// Body data is read from the given file URL
        case let .file(fileURL):
            guard let s = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? NSNumber else {
                throw _Error.fileForBodyNotFound
            }
            return s.uint64Value
        case .stream:
            return nil
        }
    }

    // Read Data
    func readData() throws -> Data? {
        switch self {
        case .none:
            return nil
        case let .data(data):
            return data
        case .stream:
            throw _Error.streamForBodyNotSuportedRead
        case let .file(fileURL):
            let fh = try FileHandle(forReadingFrom: fileURL)
            if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
                return try fh.readToEnd()
            } else {
                return fh.readDataToEndOfFile()
            }
        }
    }

    /// The 64-bit CRC value of the object. This value is calculated based on the ECMA-182 standard.
    /// This value is used to verify the integrity of the object.
    func hashCrc64ecma(crc: UInt64 = 0) -> UInt64? {
        switch self {
        case .none:
            return 0
        case let .data(data):
            return data.withUnsafeBytes { dataBytes in
                let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return CRC64.default.crc64(crc: crc, buf: buffer, len: dataBytes.count)
            }
        case let .file(url):
            guard let input = InputStream(url: url) else {
                return nil
            }
            input.open()
            let bufferSize = 16 * 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            var crc = crc
            while input.hasBytesAvailable {
                let read = input.read(buffer, maxLength: bufferSize)
                crc = CRC64.default.crc64(crc: crc, buf: buffer, len: read)
            }
            buffer.deallocate()
            input.close()
            return crc
        case .stream:
            return nil
        }
    }
}
