import Crypto
import Foundation

public class SignerV1: Signer {
    static let rfc822Datetime = createDateFormatter(dateFormat: "EE, dd MMM yyyy HH:mm:ss zzz")

    /// create timestamp dateformatter
    static func createDateFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    public init() {}

    public func sign(request: RequestMessage, signingContext: inout SigningContext) async throws -> RequestMessage {
        var request = request
        if signingContext.authHeader {
            try authHeader(request: &request, signingContext: &signingContext)
        } else {
            try authQuery(request: &request, signingContext: &signingContext)
        }
        return request
    }

    private func authHeader(request: inout RequestMessage, signingContext: inout SigningContext) throws {
        // setp 1
        preAuthHeader(request: &request, context: &signingContext)

        // setp 2
        let sigingKey = try calcSigningKey(context: &signingContext)

        // setp 3
        let signature = try calcSignature(signingKey: sigingKey, signToString: signingContext.stringToSign)

        // setp 4
        postAuthHeader(request: &request, context: &signingContext, signature: signature)
    }

    private func authQuery(request: inout RequestMessage, signingContext: inout SigningContext) throws {
        // setp 1
        preAuthQuery(request: &request, context: &signingContext)

        // setp 2
        let sigingKey = try calcSigningKey(context: &signingContext)

        // setp 3
        let signature = try calcSignature(signingKey: sigingKey, signToString: signingContext.stringToSign)

        // setp 4
        postAuthQuery(request: &request, context: &signingContext, signature: signature)
    }

    /// add credential information and calc StringToSign for request
    func preAuthHeader(request: inout RequestMessage, context: inout SigningContext) {
        guard let credentials = context.credentials else {
            return
        }
        let dateTime = context.signTime ?? Date().addingTimeInterval(context.clockOffset ?? 0)
        let date = Self.rfc822Datetime.string(from: dateTime)

        // add date header
        request.headers["Date"] = date
        request.headers["x-oss-security-token"] = credentials.securityToken

        let stringToSign = buildStringToSign(request: request,
                                             resourcePath: resourcePath(bucket: context.bucket, key: context.key),
                                             date: date,
                                             headers: request.headers,
                                             subResource: context.subResource)
        context.stringToSign = stringToSign
        context.dateToSign = date
    }

    /// update authorization header
    func postAuthHeader(request: inout RequestMessage, context: inout SigningContext, signature: String) {
        guard let credentials = context.credentials else {
            return
        }
        request.headers["Authorization"] = "OSS \(credentials.accessKeyId):\(signature)"
    }

    /// add credential information and calc StringToSign for request
    func preAuthQuery(request: inout RequestMessage, context: inout SigningContext) {
        guard let credentials = context.credentials else {
            return
        }
        let expirationTime = context.expirationTime ?? Date().addingTimeInterval(context.clockOffset ?? 0).addingTimeInterval(15 * 60)
        let expiration = Int(expirationTime.timeIntervalSince1970)
        context.expirationTime = expirationTime

        var queryItems: [URLQueryItem] = []
        if let securityToken = credentials.securityToken {
            queryItems.append(URLQueryItem(name: "security-token", value: securityToken.urlEncode()))
        }
        request.requestUri = request.requestUri.appending(queryItems)

        let stringToSign = buildStringToSign(request: request,
                                             resourcePath: resourcePath(bucket: context.bucket, key: context.key),
                                             date: "\(expiration)",
                                             headers: request.headers,
                                             subResource: context.subResource)
        context.stringToSign = stringToSign
        context.dateToSign = "\(expiration)"
    }

    func postAuthQuery(request: inout RequestMessage, context: inout SigningContext, signature: String) {
        guard let credentials = context.credentials else {
            return
        }
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "OSSAccessKeyId", value: credentials.accessKeyId.urlEncode()))
        queryItems.append(URLQueryItem(name: "Signature", value: signature.urlEncode()))
        queryItems.append(URLQueryItem(name: "Expires", value: "\(context.dateToSign)"))
        request.requestUri = request.requestUri.appending(queryItems)
    }

    private func buildStringToSign(request: RequestMessage,
                                   resourcePath: String,
                                   date: String,
                                   headers: [String: String],
                                   subResource: [String]?) -> String
    {
        let method = request.method
        let contentMD5 = request.headers["Content-MD5"] ?? ""
        let contentType = request.headers["Content-Type"] ?? ""
        let canonicalizedOSSHeaders = canonicalizedOSSHeaders(headers)

        let queryItems = URLComponents(url: request.requestUri, resolvingAgainstBaseURL: false)?.queryItems
        let canonicalizedResource = canonicalizedResource(resourcePath: resourcePath,
                                                          queryItems: queryItems,
                                                          subResource: subResource)
        // format content
        let stringToSign =
            """
            \(method)\n\
            \(contentMD5)\n\
            \(contentType)\n\
            \(date)\n\
            \(canonicalizedOSSHeaders)\
            \(canonicalizedResource)
            """
        // print("StringToSign: \(stringToSign)")

        return stringToSign
    }

    private func canonicalizedOSSHeaders(_ headers: [String: String]) -> String {
        var _headers: [String: String] = [:]
        for (key, value) in headers {
            _headers[key.lowercased()] = value
        }
        let canonicalizedOSSHeaders = _headers.sorted {
            $0.key < $1.key
        }.map {
            "\($0.key):\($0.value)"
        }.filter {
            $0.hasPrefix("x-oss-")
        }.joined(separator: "\n")

        return _headers.count > 0 ? canonicalizedOSSHeaders.appending("\n") : canonicalizedOSSHeaders
    }

    private func canonicalizedResource(resourcePath: String, queryItems: [URLQueryItem]?, subResource: [String]?) -> String {
        if let queryItems = queryItems {
            let querys = queryItems.filter {
                signerResourceFlag.contains($0.name) ||
                    signerResponseFlag.contains($0.name) ||
                    $0.name == signerProcessFlag ||
                    $0.name.hasPrefix(signerAccessFlag) ||
                    (subResource?.contains($0.name) ?? false)
            }.compactMap {
                if let name = $0.name.trim().urlEncode() {
                    return URLQueryItem(name: name, value: $0.value)
                }
                return nil
            }.sorted {
                $0.name < $1.name
            }.map {
                if let value = $0.value?.trim().urlEncode(),
                   !value.isEmpty
                {
                    return "\($0.name)=\(value)"
                } else {
                    return "\($0.name)"
                }
            }
            if querys.count > 0 {
                return resourcePath.appending("?\(querys.joined(separator: "&"))")
            }
        }
        return resourcePath
    }

    func resourcePath(bucket: String?, key: String?) -> String {
        var resourcePath = "/" + (bucket ?? "") + (key != nil ? "/" + key! : "")
        if bucket != nil && key == nil {
            resourcePath = resourcePath + "/"
        }
        return resourcePath
    }

    func calcSigningKey(context: inout SigningContext) throws -> SymmetricKey {
        let key = context.credentials?.accessKeySecret.data(using: .utf8)!
        return SymmetricKey(data: key!)
    }

    func calcSignature(signingKey: SymmetricKey, signToString: String) throws -> String {
        let content = signToString.data(using: .utf8)!
        return Data(HMAC<Insecure.SHA1>.authenticationCode(for: content, using: signingKey)).base64EncodedString()
    }
}

extension URL {
    var queryItems: [URLQueryItem]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        return components.queryItems
    }

    func appending(_ items: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return absoluteURL }

        var queryItems = components.queryItems ?? []
        queryItems.append(contentsOf: items)
        components.queryItems = queryItems

        return components.url!
    }
}
