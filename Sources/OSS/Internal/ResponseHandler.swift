
import Foundation

protocol ResponseHandler {
    func onResponse(request: RequestMessage, response: ResponseMessage) throws
}

protocol ResponseHandlerAsync: ResponseHandler {
    func onResponseAsync(request: RequestMessage, response: ResponseMessage) async throws
}

extension ResponseHandlerAsync {
    func onResponse(request _: RequestMessage, response _: ResponseMessage) throws {}
}

extension AttributeKeys {
    static let responseHandler = AttributeKey<ResponseHandler>(name: "response-handler")
}

struct ServerResponseHandler: ResponseHandler {
    func onResponse(request: RequestMessage, response: ResponseMessage) throws {
        if response.statusCode / 100 == 2 {
            return
        }

        var errorFields: [String: String] = [:]
        var body: Data?
        body = try? response.content?.readData()
        // read from x-oss-error
        if body == nil || body!.count == 0 {
            if let str = response.headers[caseInsensitive: "x-oss-error"] {
                let base64EncodedData = str.data(using: .utf8)!
                body = Data(base64Encoded: base64EncodedData)
            }
        }

        /// try to parse error message
        if let bodyData = body, bodyData.count > 0 {
            do {
                let dict = try Dictionary<String, Any>.withXMLData(data: bodyData)
                if let error = dict["Error"], let fields = error as? [String: String] {
                    for (key, value) in fields {
                        errorFields[key] = value
                    }
                } else {
                    let bodyStr = String(data: bodyData, encoding: .utf8) ?? ""
                    errorFields["Message"] =
                        "Not found tag <Error>, part response body \(bodyStr.prefix(256))"
                }
            } catch {
                let bodyStr = String(data: bodyData, encoding: .utf8) ?? ""
                errorFields["Message"] =
                    "Failed to parse xml from response body, part response body \(bodyStr.prefix(256))"
            }
        }

        throw ServerError(
            statusCode: response.statusCode,
            headers: response.headers,
            errorFields: errorFields,
            requestTarget: "\(request.method) \(request.requestUri.absoluteString)",
            snapshot: body
        )
    }
}

struct ChekerUploadCrcResponseHandler: ResponseHandler {
    private let crc: UInt64?
    init(crc: UInt64? = nil) {
        self.crc = crc
    }

    func onResponse(request: RequestMessage, response: ResponseMessage) throws {
        if response.statusCode / 100 != 2 {
            return
        }

        if let scrc = response.headers[caseInsensitive: "x-oss-hash-crc64ecma"]?.toUInt64(),
           let ccrc = request.content?.hashCrc64ecma(crc: crc ?? 0)
        {
            if scrc != ccrc {
                throw ClientError.inconsistentError(clientCrc: ccrc, serverCrc: scrc)
            }
        }
    }
}

struct ChekerDownloadCrcResponseHandler: ResponseHandler {
    func onResponse(request _: RequestMessage, response: ResponseMessage) throws {
        guard response.statusCode / 100 == 2,
              response.statusCode != 206
        else {
            return
        }

        if let scrc = response.headers[caseInsensitive: "x-oss-hash-crc64ecma"]?.toUInt64(),
           let ccrc = response.content?.hashCrc64ecma()
        {
            if scrc != ccrc {
                throw ClientError.inconsistentError(clientCrc: ccrc, serverCrc: scrc)
            }
        }
    }
}
