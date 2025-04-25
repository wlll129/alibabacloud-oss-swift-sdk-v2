import Crypto
import Foundation

public class SignerV4: Signer {
    static let rfc822Datetime = createDateFormatter(dateFormat: "EE, dd MMM yyyy HH:mm:ss zzz")
    static let iso8601Datetime = createDateFormatter(dateFormat: "yyyyMMdd'T'HHmmss'Z'")

    public init() {}

    /// create timestamp dateformatter
    static func createDateFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    public func sign(request: RequestMessage, signingContext: inout SigningContext) async throws -> RequestMessage {
        var request = request
        if signingContext.authHeader {
            try authHeader(request: &request, signingContext: &signingContext)
        } else {
            try authQuery(request: &request, signingContext: &signingContext)
        }
        return request
    }

    /// add credential information and calc StringToSign for request
    func preAuthHeader(request: inout RequestMessage, context: inout SigningContext) {
        let cred = context.credentials!
        let region = context.region ?? ""
        let product = context.product ?? ""

        // Date
        let signTime = context.signTime ?? Date().addingTimeInterval(context.clockOffset ?? 0)
        let datetime = Self.iso8601Datetime.string(from: signTime)
        let date = String(datetime[datetime.startIndex ..< datetime.index(datetime.startIndex, offsetBy: 8)])
        let datetimeGmt = Self.rfc822Datetime.string(from: signTime)

        // Scope
        let scope = "\(date)/\(region)/\(product)/aliyun_v4_request"

        // Credential information signature
        if let securityToken = cred.securityToken, !securityToken.isEmpty {
            request.headers["x-oss-security-token"] = cred.securityToken
        }

        // Other Headers
        request.headers["x-oss-content-sha256"] = "UNSIGNED-PAYLOAD"
        request.headers["x-oss-date"] = datetime
        request.headers["Date"] = datetimeGmt

        // Lowercase request headers
        var headers: [String: String] = [:]
        for (key, value) in request.headers {
            headers[key.lowercased()] = value
        }
        // let headers = request.headers

        // Lowercase additional headers
        var additionalSignedHeaders: [String] = []
        context.additionalHeaderNames?.forEach { key in
            let lowkey = key.lowercased()
            if !(lowkey == "content-md5" ||
                lowkey == "content-type" ||
                lowkey.hasPrefix("x-oss-")) && headers.keys.contains(lowkey)
            {
                additionalSignedHeaders.append(lowkey)
            }
        }

        // CanonicalRequest
        let canonicalRequest = calcCanonicalRequest(
            request: request,
            resourcePath: resourcePath(bucket: context.bucket, key: context.key),
            headers: headers,
            additionalHeaders: additionalSignedHeaders
        )

        // StringToSign
        context.stringToSign = calcStringToSign(datetime: datetime, scope: scope, canonicalRequest: canonicalRequest)
        context.dateToSign = date
        context.scopeToSign = scope
        context.additionalHeadersToSign = additionalSignedHeaders.sorted().joined(separator: ";")
    }

    /// update authorization header
    func postAuthHeader(request: inout RequestMessage, context: inout SigningContext, signature: String) {
        let credential = "OSS4-HMAC-SHA256 Credential=\(context.credentials!.accessKeyId)/\(context.scopeToSign)"
        let signedHeaders = context.additionalHeadersToSign == "" ? "" : ",AdditionalHeaders=\(context.additionalHeadersToSign)"
        request.headers["Authorization"] = "\(credential)\(signedHeaders),Signature=\(signature)"
    }

    /// add credential information and calc StringToSign for request
    func preAuthQuery(request: inout RequestMessage, context: inout SigningContext) {
        let cred = context.credentials!
        let region = context.region ?? ""
        let product = context.product ?? ""

        // Date
        let signTime = context.signTime ?? Date().addingTimeInterval(context.clockOffset ?? 0)
        let datetime = Self.iso8601Datetime.string(from: signTime)
        let date = String(datetime[datetime.startIndex ..< datetime.index(datetime.startIndex, offsetBy: 8)])

        // Expiration
        let expiration = context.expirationTime ?? signTime.addingTimeInterval(15 * 60)
        let expires = Int(expiration.timeIntervalSince1970 - signTime.timeIntervalSince1970)
        context.expirationTime = expiration

        // Scope
        let scope = "\(date)/\(region)/\(product)/aliyun_v4_request"

        // Other Headers

        // Lowercase request headers
        var headers: [String: String] = [:]
        for (key, value) in request.headers {
            headers[key.lowercased()] = value
        }

        // Lowercase additional headers
        var additionalSignedHeaders: [String] = []
        context.additionalHeaderNames?.forEach { key in
            let lowkey = key.lowercased()
            if !(lowkey == "content-md5" ||
                lowkey == "content-type" ||
                lowkey.hasPrefix("x-oss-")) && headers.keys.contains(lowkey)
            {
                additionalSignedHeaders.append(lowkey)
            }
        }

        // Credential information signature
        var query = request.requestUri.query ?? ""
        if query.count > 0 {
            query += "&"
        }
        query += "x-oss-signature-version=OSS4-HMAC-SHA256"
        query += "&x-oss-date=\(datetime)"
        query += "&x-oss-expires=\(expires)"
        let credentialQuery = "\(cred.accessKeyId)/\(scope)"
        query += "&x-oss-credential=\(credentialQuery.urlEncode()!)"

        if additionalSignedHeaders.count > 0 {
            let addHeaderStr = additionalSignedHeaders.sorted().joined(separator: ";")
            query += "&x-oss-additional-headers=\(addHeaderStr.urlEncode()!)"
        }

        if let securityToken = cred.securityToken, !securityToken.isEmpty {
            query += "&x-oss-security-token=\(securityToken.urlEncode()!)"
        }
        request.requestUri = URL(string: request.requestUri.absoluteString.split(separator: "?")[0] + "?" + query)!

        // CanonicalRequest
        let canonicalRequest = calcCanonicalRequest(
            request: request,
            resourcePath: resourcePath(bucket: context.bucket, key: context.key),
            headers: headers,
            additionalHeaders: additionalSignedHeaders
        )

        // StringToSign
        context.stringToSign = calcStringToSign(datetime: datetime, scope: scope, canonicalRequest: canonicalRequest)
        context.dateToSign = date
        context.scopeToSign = scope
        context.additionalHeadersToSign = additionalSignedHeaders.sorted().joined(separator: ";")
    }

    func postAuthQuery(request: inout RequestMessage, context _: inout SigningContext, signature: String) {
        // Credential
        var query = request.requestUri.query ?? ""
        query += "&x-oss-signature=\(signature)"
        request.requestUri = URL(string: request.requestUri.absoluteString.split(separator: "?")[0] + "?" + query)!
    }

    func calcCanonicalRequest(request: RequestMessage, resourcePath: String, headers: [String: String], additionalHeaders: [String]) -> String {
        /*
         Canonical Request
         HTTP Verb + "\n" +
         Canonical URI + "\n" +
         Canonical Query String + "\n" +
         Canonical Headers + "\n" +
         Additional Headers + "\n" +
         Hashed PayLoad
         */
        let verb = request.method.uppercased()

        let canonicalUri = resourcePath.urlEncodeWithoutSeparator()!

        let canonicalQueries: String
        let urlComps = URLComponents(url: request.requestUri, resolvingAgainstBaseURL: false)!
        let queryItems = urlComps.queryItems
        // print("queryItems: \(queryItems)\n")
        if queryItems != nil {
            canonicalQueries = queryItems!
                .map { (name: $0.name.urlEncode()!, value: $0.value?.urlEncode()) }
                .sorted { $0.name < $1.name }
                .map {
                    if let value = $0.value, value != "" {
                        return "\($0.name)=\(value)"
                    }
                    return "\($0.name)"
                }
                .joined(separator: "&")
        } else {
            canonicalQueries = ""
        }

        let canonicalHeaders = headers
            .filter {
                if $0.key == "content-md5" ||
                    $0.key == "content-type" ||
                    $0.key.hasPrefix("x-oss-") ||
                    additionalHeaders.contains($0.key)
                {
                    return true
                }
                return false
            }
            .map { (key: $0.key, value: $0.value.trim()) }
            .sorted { $0.key < $1.key }
            .map { "\($0.key):\($0.value)\n" }
            .joined(separator: "")

        let canonicalAdditionalHeaders = additionalHeaders
            .sorted()
            .joined(separator: ";")

        let hashedPayLoad = headers["x-oss-content-sha256"] ?? "UNSIGNED-PAYLOAD"

        let canonicalRequest =
            """
            \(verb)\n\
            \(canonicalUri)\n\
            \(canonicalQueries)\n\
            \(canonicalHeaders)\n\
            \(canonicalAdditionalHeaders)\n\
            \(hashedPayLoad)
            """

        // print("canonicalRequest:\n\(canonicalRequest)\n")

        return canonicalRequest
    }

    func calcStringToSign(datetime: String, scope: String, canonicalRequest: String) -> String {
        /*
         StringToSign
         "OSS4-HMAC-SHA256" + "\n" +
         TimeStamp + "\n" +
         Scope + "\n" +
         Hex(SHA256Hash(Canonical Request))
         */
        let h = SHA256.hash(data: canonicalRequest.data(using: .utf8)!)
        let hexDigest = h.compactMap { String(format: "%02x", $0) }.joined()

        let stringToSign =
            """
            OSS4-HMAC-SHA256\n\
            \(datetime)\n\
            \(scope)\n\
            \(hexDigest)
            """

        // print("stringToSign:\n\(stringToSign)\n")
        return stringToSign
    }

    func resourcePath(bucket: String?, key: String?) -> String {
        var resourcePath = "/" + (bucket ?? "") + (key != nil ? "/" + key! : "")
        if bucket != nil && key == nil {
            resourcePath = resourcePath + "/"
        }
        return resourcePath
    }

    func calcSigningKey(context: inout SigningContext) -> SymmetricKey {
        let region = context.region ?? ""
        let product = context.product ?? ""
        let kDate = HMAC<SHA256>.authenticationCode(
            for: context.dateToSign.data(using: .utf8)!,
            using: SymmetricKey(data: Array("aliyun_v4\(context.credentials!.accessKeySecret)".utf8))
        )
        let kRegion = HMAC<SHA256>.authenticationCode(for: region.data(using: .utf8)!, using: SymmetricKey(data: kDate))
        let kProduct = HMAC<SHA256>.authenticationCode(for: product.data(using: .utf8)!, using: SymmetricKey(data: kRegion))
        let kSigning = HMAC<SHA256>.authenticationCode(for: [UInt8]("aliyun_v4_request".utf8), using: SymmetricKey(data: kProduct))
        return SymmetricKey(data: kSigning)
    }

    func calcSignature(signingKey: SymmetricKey, signToString: String) -> String {
        let kSignature = HMAC<SHA256>.authenticationCode(
            for: signToString.data(using: .utf8)!,
            using: signingKey
        )
        return kSignature.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func authHeader(request: inout RequestMessage, signingContext: inout SigningContext) throws {
        // setp 1
        preAuthHeader(request: &request, context: &signingContext)

        // setp 2
        let sigingKey = calcSigningKey(context: &signingContext)

        // setp 3
        let signature = calcSignature(signingKey: sigingKey, signToString: signingContext.stringToSign)

        // setp 4
        postAuthHeader(request: &request, context: &signingContext, signature: signature)
    }

    private func authQuery(request: inout RequestMessage, signingContext: inout SigningContext) throws {
        // setp 1
        preAuthQuery(request: &request, context: &signingContext)

        // setp 2
        let sigingKey = calcSigningKey(context: &signingContext)

        // setp 3
        let signature = calcSignature(signingKey: sigingKey, signToString: signingContext.stringToSign)

        // setp 4
        postAuthQuery(request: &request, context: &signingContext, signature: signature)
    }
}
