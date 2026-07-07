import Foundation

public class UploaderOptions: @unchecked Sendable {
    public var partSize: Int
    public var parallelNum: Int
    public var leavePartsOnError: Bool
    public var enableCheckpoint: Bool?
    public var checkpointDir: String?
    
    init(
        partSize: Int,
        parallelNum: Int,
        leavePartsOnError: Bool,
        enableCheckpoint: Bool? = nil,
        checkpointDir: String? = nil
    ) {
        self.partSize = partSize
        self.parallelNum = parallelNum
        self.leavePartsOnError = leavePartsOnError
        self.enableCheckpoint = enableCheckpoint
        self.checkpointDir = checkpointDir
    }
}

public struct UploadResult: ResultModel, Sendable {
    public var commonProp: ResultModelProp
    
    /// The upload ID that uniquely identifies the multipart upload task.
    public var uploadId: String?
    
    /// The entity tag (ETag). An ETag is created when the object is created to identify the content of an object.
    /// For an object that is created by calling the PutObject operation, the ETag value of the object is the MD5 hash of the object content.
    /// For an object that is created by using another method, the ETag value is not the MD5 hash of the object content but a unique value calculated based on a specific rule.
    /// The ETag of an object can be used to check whether the object content changes. However, we recommend that you use the MD5 hash of an object rather than the ETag value of the object to verify data integrity.
    public var eTag: String?
    
    /// The version id of the target object.
    public var versionId: String?
    
    /// The 64-bit CRC value of the object. This value is calculated based on the ECMA-182 standard.
    public var hashCRC64: UInt64?
}

actor TransferredInfo {
    public private(set) var parts: [UploadPartCRC]
    public private(set) var transferred: Int64
    
    init(
        parts: [UploadPartCRC] = [],
        transferred: Int64 = 0
    ) {
        self.parts = parts
        self.transferred = transferred
    }
    
    public func transferred(_ part: UploadPartCRC) {
        parts.append(part)
        transferred += Int64(part.size)
    }
}

struct UploadPartCRC {
    let uploadPart: UploadPart
    let crcValue: UInt64?
    let size: Int
}
