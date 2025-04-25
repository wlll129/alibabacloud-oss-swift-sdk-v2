@testable import AlibabaCloudOSS

public struct PutApiRequest: RequestModel {
    public var commonProp: RequestModelProp = .init()
    public var bucket: String?
    public var key: String?
    public var acl: String?
    public var metadata: [String: String]?
    init(
        bucket: String? = nil,
        key: String? = nil,
        acl: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.bucket = bucket
        self.key = key
        self.acl = acl
        self.metadata = metadata
    }
}

public struct PutApiXmlResult {
    public var strValue: String?
    public var StrValue1: String?
}

public struct PutApiResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    public var headerStr: String? { return commonProp.headers?["x-oss-header-str"] }
    public var headerInt: Int? { return commonProp.headers?["x-oss-header-int"]?.toInt() }
    public var headerBool: Bool? { return commonProp.headers?["x-oss-header-bool"]?.toBool() }

    public var xmlResult: PutApiXmlResult?
}
