import Foundation

// MARK: - PutBucketAcl

extension Serde {
    static func serializePutBucketAcl(
        _ request: inout PutBucketAclRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.acl {
            input.headers["x-oss-acl"] = value
        }
    }

    static func deserializePutBucketAcl(
        _: inout PutBucketAclResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetBucketAcl

extension Serde {
    static func serializeGetBucketAcl(
        _: inout GetBucketAclRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeGetBucketAcl(
        _ result: inout GetBucketAclResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "AccessControlPolicy")

        var accessControlPolicy = AccessControlPolicy()
        if let accessControlList = body["AccessControlList"] as? [String: String] {
            accessControlPolicy.accessControlList = AccessControlList(grant: accessControlList["Grant"])
        }
        if let ownerData = body["Owner"] as? [String: String] {
            var owner = Owner()
            owner.displayName = ownerData["DisplayName"]
            owner.id = ownerData["ID"]
            accessControlPolicy.owner = owner
        }
        result.accessControlPolicy = accessControlPolicy
    }
}
