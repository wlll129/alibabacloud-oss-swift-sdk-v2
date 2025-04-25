import Foundation

// MARK: - PutSymlink

extension Serde {
    static func serializePutSymlink(
        _ request: inout PutSymlinkRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.symlinkTarget {
            input.headers["x-oss-symlink-target"] = value
        }

        if let value = request.objectAcl {
            input.headers["x-oss-object-acl"] = value
        }

        if let value = request.storageClass {
            input.headers["x-oss-storage-class"] = value
        }

        if let value = request.forbidOverwrite {
            input.headers["x-oss-forbid-overwrite"] = value.toString()
        }
    }

    static func deserializePutSymlink(
        _: inout PutSymlinkResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetSymlink

extension Serde {
    static func serializeGetSymlink(
        _ request: inout GetSymlinkRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.versionId {
            input.parameters["versionId"] = value
        }
    }

    static func deserializeGetSymlink(
        _: inout GetSymlinkResult,
        _: inout OperationOutput
    ) throws {}
}
