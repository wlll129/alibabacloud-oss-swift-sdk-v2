import Foundation

// MARK: - PutObjectAcl

extension Serde {
    static func serializePutObjectAcl(
        _ request: inout PutObjectAclRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.objectAcl {
            input.headers["x-oss-object-acl"] = value
        }

        if let value = request.versionId {
            input.parameters["versionId"] = value
        }
    }

    static func deserializePutObjectAcl(
        _: inout PutObjectAclResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetObjectAcl

extension Serde {
    static func serializeGetObjectAcl(
        _ request: inout GetObjectAclRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.versionId {
            input.parameters["versionId"] = value
        }
    }

    static func deserializeGetObjectAcl(
        _ result: inout GetObjectAclResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "AccessControlPolicy")

        var accessControlPolicy = AccessControlPolicy()
        if let accessControlList = body["AccessControlList"] as? [String: Any],
           let grant = accessControlList["Grant"] as? String
        {
            accessControlPolicy.accessControlList = AccessControlList(grant: grant)
        }
        if let own = body["Owner"] as? [String: Any] {
            var owner = Owner()
            if let id = own["ID"] as? String {
                owner.id = id
            }
            if let displayName = own["DisplayName"] as? String {
                owner.displayName = displayName
            }
            accessControlPolicy.owner = owner
        }
        result.accessControlPolicy = accessControlPolicy
    }
}
