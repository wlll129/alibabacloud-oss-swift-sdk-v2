import Foundation

public struct RequestModelProp: Sendable {
    public var headers: [String: String]?
    public var parameters: [String: String?]?

    public init(
        headers: [String: String]? = nil,
        parameters: [String: String?]? = nil
    ) {
        self.headers = headers
        self.parameters = parameters
    }
}

public protocol RequestModel: Sendable {
    var commonProp: RequestModelProp { get set }
    mutating func addHeader(_ key: String, _ value: String)
    mutating func addParameter(_ key: String, _ value: String?)
}

public extension RequestModel {
    mutating func addHeader(_ key: String, _ value: String) {
        if commonProp.headers == nil {
            commonProp.headers = [String: String]()
        }
        commonProp.headers![key.lowercased()] = value
    }

    mutating func addParameter(_ key: String, _ value: String?) {
        if commonProp.parameters == nil {
            commonProp.parameters = [String: String?]()
        }
        commonProp.parameters![key] = value
    }
}

public struct ResultModelProp: Sendable {
    public var statusCode: Int = 0
    public var headers: [String: String]? = nil
    public init() {}
}

public protocol ResultModel {
    var commonProp: ResultModelProp { get set }
}

public extension ResultModel {
    var statusCode: Int { return commonProp.statusCode }
    var headers: [String: String]? { return commonProp.headers }
    var requestId: String { return commonProp.headers?[caseInsensitive: "x-oss-request-id"] ?? "" }
}
