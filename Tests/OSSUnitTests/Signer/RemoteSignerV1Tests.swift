@testable import AlibabaCloudOSS
import Crypto
import XCTest

final class RemoteSignerV1Tests: XCTestCase {
    func testAuthHeader() async throws {
        let ak = "ak"
        let sk = "sk"
        let signTime = Date(timeIntervalSince1970: 1_672_223_261)

        let credentials = Credentials(accessKeyId: ak,
                                      accessKeySecret: sk)
        var signingContext = SigningContext(bucket: "examplebucket",
                                            key: "nelson",
                                            signTime: signTime,
                                            credentials: credentials)
        let signer = RemoteSignerV1(delegate: SignatureImpl())

        // case 1
        var uri = URL(string: "http://examplebucket.oss-cn-hangzhou.aliyuncs.com")!
        var request = RequestMessage(method: "PUT", requestUri: uri)
        request.headers["Content-MD5"] = "eB5eJF1ptWaXm4bijSPyxw=="
        request.headers["Content-Type"] = "text/html"
        request.headers["x-oss-meta-author"] = "alice"
        request.headers["x-oss-meta-magic"] = "abracadabra"
        request.headers["x-oss-date"] = "Wed, 28 Dec 2022 10:27:41 GMT"
        request = try await signer.sign(request: request,
                                        signingContext: &signingContext)
        XCTAssertEqual(request.headers["Authorization"], "OSS ak:kSHKmLxlyEAKtZPkJhG9bZb5k7M=")

        // With Signed Parameter
        uri = URL(string: "http://examplebucket.oss-cn-hangzhou.aliyuncs.com?acl")!
        request = RequestMessage(method: "PUT", requestUri: uri)
        request.headers["Content-MD5"] = "eB5eJF1ptWaXm4bijSPyxw=="
        request.headers["Content-Type"] = "text/html"
        request.headers["x-oss-meta-author"] = "alice"
        request.headers["x-oss-meta-magic"] = "abracadabra"
        request.headers["x-oss-date"] = "Wed, 28 Dec 2022 10:27:41 GMT"
        request = try await signer.sign(request: request,
                                        signingContext: &signingContext)
        XCTAssertEqual(request.headers["Authorization"], "OSS ak:/afkugFbmWDQ967j1vr6zygBLQk=")

        // With signed & non-signed Parameter & non-signed headers
        uri = URL(string: "http://examplebucket.oss-cn-hangzhou.aliyuncs.com?acl&non-resousce=123")!
        request = RequestMessage(method: "PUT", requestUri: uri)
        request.headers["Content-MD5"] = "eB5eJF1ptWaXm4bijSPyxw=="
        request.headers["Content-Type"] = "text/html"
        request.headers["x-oss-meta-author"] = "alice"
        request.headers["x-oss-meta-magic"] = "abracadabra"
        request.headers["x-oss-date"] = "Wed, 28 Dec 2022 10:27:41 GMT"
        request.headers["User-Agent"] = "test"
        request = try await signer.sign(request: request,
                                        signingContext: &signingContext)
        XCTAssertEqual(request.headers["Authorization"], "OSS ak:/afkugFbmWDQ967j1vr6zygBLQk=")

        // With sub-resource
        uri = URL(string: "http://examplebucket.oss-cn-hangzhou.aliyuncs.com?resourceGroup&non-resousce=null")!
        signingContext = SigningContext(bucket: "examplebucket",
                                        signTime: signTime,
                                        credentials: credentials,
                                        subResource: ["resourceGroup"])
        request = RequestMessage(method: "GET", requestUri: uri)
        request.headers["x-oss-date"] = "Wed, 28 Dec 2022 10:27:41 GMT"
        request = try await signer.sign(request: request,
                                        signingContext: &signingContext)
        XCTAssertEqual(request.headers["Authorization"], "OSS ak:vkQmfuUDyi1uDi3bKt67oemssIs=")
    }

    func testAuthQuery() async throws {
        let ak = "ak"
        let sk = "sk"
        let signTime = Date(timeIntervalSince1970: 1_699_807_420)

        let credentials = Credentials(accessKeyId: ak,
                                      accessKeySecret: sk)
        var signingContext = SigningContext(bucket: "bucket",
                                            key: "key",
                                            signTime: signTime,
                                            credentials: credentials,
                                            expirationTime: signTime)
        signingContext.authHeader = false
        let signer = RemoteSignerV1(delegate: SignatureImpl())

        // case 1
        let uri = URL(string: "http://bucket.oss-cn-hangzhou.aliyuncs.com/key?versionId=versionId")!
        var request = RequestMessage(method: "GET", requestUri: uri)
        request = try await signer.sign(request: request,
                                        signingContext: &signingContext)
        XCTAssertEqual(request.requestUri.queryItems?["OSSAccessKeyId"], "ak")
        XCTAssertEqual(request.requestUri.queryItems?["Expires"], "1699807420")
        XCTAssertEqual(request.requestUri.queryItems?["Signature"], "dcLTea%2BYh9ApirQ8o8dOPqtvJXQ%3D")
        XCTAssertEqual(request.requestUri.queryItems?["versionId"], "versionId")
    }
}

private struct SignatureImpl: SignatureDelegate {
    public func signature(info: [String: String]) async throws -> [String: String] {
        let stringToSign = info["stringToSign"] ?? ""

        // setp 2
        let accessKeySecret = "sk"
        let sigingKey = try calcSigningKey(
            accessKeySecret: accessKeySecret
        )

        // setp 3
        let signature = try calcSignature(signingKey: sigingKey, signToString: stringToSign)

        return [
            "signature": signature,
        ]
    }

    func calcSigningKey(accessKeySecret: String) throws -> SymmetricKey {
        if let key = accessKeySecret.data(using: .utf8) {
            return SymmetricKey(data: key)
        }
        throw UnitTestError("signature with hmacsha1 failed!")
    }

    func calcSignature(signingKey: SymmetricKey, signToString: String) throws -> String {
        if let content = signToString.data(using: .utf8) {
            return Data(HMAC<Insecure.SHA1>.authenticationCode(for: content, using: signingKey)).base64EncodedString()
        }
        throw UnitTestError("signature with hmacsha1 failed!")
    }
}
