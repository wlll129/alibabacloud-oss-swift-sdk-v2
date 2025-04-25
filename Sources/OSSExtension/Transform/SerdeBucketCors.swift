import AlibabaCloudOSS
import Foundation
import XMLCoder

// MARK: - PutBucketCors

extension Serde {
    static func serializePutBucketCors(
        _ request: inout PutBucketCorsRequest,
        _ input: inout OperationInput
    ) throws {
        let data: Data = try XMLEncoder().encode(request.corsConfiguration, withRootKey: "CORSConfiguration")
        input.body = .data(data)
    }

    static func deserializePutBucketCors(
        _: inout PutBucketCorsResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetBucketCors

extension Serde {
    static func serializeGetBucketCors(
        _: inout GetBucketCorsRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeGetBucketCors(
        _ result: inout GetBucketCorsResult,
        _ output: inout OperationOutput
    ) throws {
        guard let data = try output.body?.readData() else {
            throw ClientError.parseResponseBodyError(info: "Can not get response body.")
        }
        let corsConfiguration = try XMLDecoder().decode(CORSConfiguration.self, from: data)
        result.corsConfiguration = corsConfiguration
    }
}

// MARK: - DeleteBucketCors

extension Serde {
    static func serializeDeleteBucketCors(
        _: inout DeleteBucketCorsRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeDeleteBucketCors(
        _: inout DeleteBucketCorsResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - OptionObject

extension Serde {
    static func serializeOptionObject(
        _ request: inout OptionObjectRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.origin {
            input.headers["Origin"] = value
        }
        if let value = request.accessControlRequestMethod {
            input.headers["Access-Control-Request-Method"] = value
        }
        if let value = request.accessControlRequestHeaders {
            input.headers["Access-Control-Request-Headers"] = value
        }
    }

    static func deserializeOptionObject(
        _: inout OptionObjectResult,
        _: inout OperationOutput
    ) throws {}
}
