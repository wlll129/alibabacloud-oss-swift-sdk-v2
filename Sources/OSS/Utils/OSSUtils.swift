
import Foundation
import Crypto
#if os(Windows)
    import WinSDK
#elseif canImport(Android)
    @preconcurrency import Android
#endif

open class OSSUtils {
    public static func regionToEndpoint(region: String, type: EndpointType) -> String {
        switch type {
        case .defautt:
            return "oss-\(region).aliyuncs.com"
        case .internal:
            return "oss-\(region)-internal.aliyuncs.com"
        case .accelerate:
            return "oss-accelerate.aliyuncs.com"
        case .dualstack:
            return "\(region).oss.aliyuncs.com"
        case .overseas:
            return "oss-accelerate-overseas.aliyuncs.com"
        }
    }
    
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
                autoreleasepool {
                    let data = fileHandle.readData(ofLength: chunkSize)
                    if data.count == 0 {
                        done = true
                    }
                    md5.update(data: data)
                }
            }

            return Data(md5.finalize())
        } catch {
            throw ClientError.fileOperationError(filePath: url.path,
                                                 operation: "Open file error",
                                                 innerError: error)
        }
    }
}

// MARK: verify endpoint/bucket/objectKey

public extension String {
    func urlEncode() -> String? {
        let urlOssAllowed = CharacterSet.urlOssAllowed
        let urlString = addingPercentEncoding(withAllowedCharacters: urlOssAllowed)
        return urlString
    }

    func urlEncodePath() -> String? {
        var urlOssAllowed = CharacterSet.urlOssAllowed
        urlOssAllowed.insert(charactersIn: ("/" as Unicode.Scalar) ... ("/" as Unicode.Scalar))
        let urlString = addingPercentEncoding(withAllowedCharacters: urlOssAllowed)
        return urlString
    }

    func urlEncodeWithoutSeparator() -> String? {
        var urlOssAllowed = CharacterSet.urlOssAllowed
        urlOssAllowed.insert(charactersIn: ("/" as Unicode.Scalar) ... ("/" as Unicode.Scalar))
        let urlString = addingPercentEncoding(withAllowedCharacters: urlOssAllowed)
        return urlString
    }

    private func isValid(pattern: String) throws -> Bool {
        let regular = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        let matches = regular.matches(in: self, options: .reportCompletion, range: .init(location: 0, length: count))
        return matches.count > 0
    }

    func isValidBucketName() throws -> Bool {
        return try isValid(pattern: Pattern.bucketNamePattern.rawValue)
    }

    func isValidObjectKey() throws -> Bool {
        return count >= 1 && count <= 1024
    }

    func escape() -> String {
        var escapeString = ""
        for char in self {
            switch char {
            case "&":
                escapeString.append("&amp;")
            case "<":
                escapeString.append("&lt;")
            case ">":
                escapeString.append("&gt;")
            case "\"":
                escapeString.append("&quot;")
            case "\'":
                escapeString.append("&apos;")
            default:
                escapeString.append(char)
            }
        }
        return escapeString
    }

    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

// MARK: ipv4 or ipv6 address

extension String {
    func isIPAddress() -> Bool {
        var in4Addr = in_addr()
        if inet_pton(AF_INET, self, &in4Addr) == 1 {
            return true
        }
        var in6Addr = in6_addr()
        if inet_pton(AF_INET6, self, &in6Addr) == 1 {
            return true
        }
        return false
    }
}

public extension Dictionary {
    func toBase64JsonString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self)
            let jsonString = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\\/", with: "/")
            return jsonString?.data(using: .utf8)?.base64EncodedString() ?? "e30="
        } catch {
            // Logger.error("Failed to convert to base64 string: \(error)")
            return "e30="
        }
    }

    func encodedQuery() -> String {
        var queryParameters: [String] = []
        for object in self {
            if let key = object.key as? String,
               let urlEncodedKey = key.urlEncode(),
               let value = object.value as? String,
               let urlEncodedValue = value.urlEncode()
            {
                let parameter = urlEncodedValue == "" ? "\(urlEncodedKey)" : "\(urlEncodedKey)=\(urlEncodedValue)"
                queryParameters.append(parameter)
            }
        }
        return queryParameters.joined(separator: "&")
    }
}

public extension CharacterSet {
    static var urlOssAllowed: CharacterSet {
        let ranges = [("a" as Unicode.Scalar) ... ("z" as Unicode.Scalar),
                      ("A" as Unicode.Scalar) ... ("Z" as Unicode.Scalar),
                      ("0" as Unicode.Scalar) ... ("9" as Unicode.Scalar),
                      ("." as Unicode.Scalar) ... ("." as Unicode.Scalar),
                      ("~" as Unicode.Scalar) ... ("~" as Unicode.Scalar),
                      ("-" as Unicode.Scalar) ... ("-" as Unicode.Scalar),
                      ("_" as Unicode.Scalar) ... ("_" as Unicode.Scalar)]

        let characterSet = ranges.reduce(into: CharacterSet()) {
            $0.insert(charactersIn: $1)
        }
        return characterSet
    }
}

extension Data {
    func hexString() -> String {
        self.compactMap { String(format: "%02x", $0) }.joined()
    }
}

public struct CaseInsensitiveString: ExpressibleByStringLiteral, Hashable, CustomStringConvertible {
    var value: String

    init(_ value: String) {
        self.value = value
    }

    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value.lowercased())
    }

    public static func == (lhs: CaseInsensitiveString, rhs: CaseInsensitiveString) -> Bool {
        return lhs.value.lowercased() == rhs.value.lowercased()
    }

    public var description: String { value }
}
