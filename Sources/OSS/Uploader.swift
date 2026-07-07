import Foundation

public typealias UploaderOptionsAction = (UploaderOptions) -> Void

public class Uploader: @unchecked Sendable {
    
    /// The oss client.
    private let client: Client
    private var options: UploaderOptions
    
    public init(
        _ client: Client,
        _ actions: UploaderOptionsAction...
    ) {
        self.client = client
        let options = UploaderOptions(
            partSize: Defaults.uploadPartSize,
            parallelNum: Defaults.uploadParallel,
            leavePartsOnError: false
        )
        
        for action in actions {
            action(options)
        }
        self.options = options
    }
    
    public func upload(_ request: PutObjectRequest) async throws -> UploadResult {
        try request.bucket.ensureRequired(field: "request.bucket")
        try request.key.ensureRequired(field: "request.key")
        let body = try request.body.ensureRequired(field: "request.body")
        guard let totalSize = try body.getBodyLength() else {
            throw ClientError.paramInvalidError(field: "Cannot obtain the size of the body")
        }
        
        let partSize = applySource(totalSize: totalSize)
        
        let delegate = UploaderDelegate(client: client,
                                        options: options,
                                        request: request,
                                        totalSize: totalSize,
                                        partSize: partSize)
        try await delegate.checkCheckpoint()
        let result = try await delegate.upload()
        
        return result
    }
    
    public func abortUpload(_ request: PutObjectRequest) async throws {
        try request.bucket.ensureRequired(field: "request.bucket")
        try request.key.ensureRequired(field: "request.key")
        let body = try request.body.ensureRequired(field: "request.body")
        guard let totalSize = try body.getBodyLength() else {
            throw ClientError.paramInvalidError(field: "Cannot obtain the size of the body")
        }
        let partSize = applySource(totalSize: totalSize)

        let delegate = UploaderDelegate(client: client,
                                        options: options,
                                        request: request,
                                        totalSize: totalSize,
                                        partSize: partSize)
        try await delegate.checkCheckpoint()
        try await delegate.abortUpload()
    }
    
    private func applySource(totalSize: UInt64) -> Int {
        var partSize = options.partSize
        while totalSize/UInt64(partSize) > Defaults.maxUploadParts {
            partSize += options.partSize
        }
        
        return partSize
    }
}

actor UploaderDelegate: Sendable {
    
    private let client: Client
    private var options: UploaderOptions
    private let request: PutObjectRequest
    private let totalSize: UInt64
    private let partSize: Int
    
    private var checkpoint: UploadCheckpoint?
    private var totalBytesTransferred: Int64 = 0
    
    private var tempFileDir: String {
        var fileDir: String
        if let catchDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            fileDir = catchDir
        } else {
            fileDir = NSHomeDirectory()
        }
        fileDir = fileDir + "/OSS"
        return fileDir
    }
    
    init(
        client: Client,
        options: UploaderOptions,
        request: PutObjectRequest,
        totalSize: UInt64,
        partSize: Int
    ) {
        self.client = client
        self.options = options
        self.request = request
        self.totalSize = totalSize
        self.partSize = partSize
    }
        
    fileprivate func checkCheckpoint() throws {
        guard options.enableCheckpoint ?? false else {
            return
        }
        guard let body = request.body,
              case .file(let fileUrl) = body else {
            return
        }
        let filePath = fileUrl.absoluteURL.path
        let baseDir = options.checkpointDir
        
        let name = "\(request.bucket!)/\(request.key!)"
        let destHash = "oss://\(name.escape())".data(using: .utf8)!.calculateMd5().hexString()
        let srcHash = filePath.data(using: .utf8)!.calculateMd5().hexString()
        
        let cpFileDir: String = baseDir ?? tempFileDir
        if !FileManager.default.fileExists(atPath: cpFileDir) {
            try FileManager.default.createDirectory(atPath: cpFileDir, withIntermediateDirectories: true)
        }
        
        let cpFilePath = cpFileDir + "/\(srcHash)-\(destHash)\(Defaults.checkpointFileSuffixUploader)"
        
        let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
        guard let size = attribute[FileAttributeKey.size] as? UInt64,
            let lastModified = attribute[FileAttributeKey.modificationDate] as? Date else {
            throw ClientError.fileOperationError(filePath: filePath, operation: "Cann't obtain file size or lastModified")
        }
        
        var checkpoint = UploadCheckpoint(
            cpDirPath: cpFileDir,
            cpFilePath: cpFilePath,
            loaded: false,
            info: UploadCheckpoint.Info(
                magic: Defaults.checkpointMagic,
                data: UploadCheckpoint.Info.Data(
                    partSize: partSize,
                    fileMeta: UploadCheckpoint.Info.Data.FileMeta(size: UInt64(size), lastModified: DateFormatter.iso8601DateTime.string(from: lastModified)),
                    objectInfo: UploadCheckpoint.Info.Data.ObjectInfo(objectKey: "oss://" + name))
            )
        )
        try checkpoint.load()
        
        options.leavePartsOnError = true
        self.checkpoint = checkpoint
    }
    
    private func getUploadId() async throws -> String {
        let result = try await client.initiateMultipartUpload(
            InitiateMultipartUploadRequest(
                bucket: request.bucket,
                key: request.key
            )
        )
        guard let uploadId = result.uploadId else {
            throw ClientError.responseError(detail: "No uploadId was obtained")
        }
        return uploadId
    }
    
    fileprivate func adjustSource(uploadId: String?) async throws -> TransferredInfo? {
        guard let uploadId = uploadId else {
            return nil
        }
        
        let transferredInfo = TransferredInfo()
        for try await result in client.listPartsPaginator(
            ListPartsRequest(
                bucket: request.bucket,
                key: request.key,
                uploadId: uploadId
            )
        ) {
            if let listParts = result.parts {
                for part in listParts {
                    guard let size = part.size else { throw ClientError.responseError(detail: "Can't get part size.") }
                    await transferredInfo.transferred(
                        UploadPartCRC(
                            uploadPart: UploadPart(etag: part.etag, partNumber: part.partNumber),
                            crcValue: part.hashCrc64?.toUInt64(),
                            size: size
                        )
                    )
                }
            }
        }
        return transferredInfo
    }
    
    fileprivate func upload() async throws -> UploadResult {
        let totalSize = totalSize
        return if totalSize > 0, totalSize <= partSize {
            try await singlePart()
        } else {
            try await multiPart()
        }
    }
    
    fileprivate func abortUpload() async throws {
        let _ = try await client.abortMultipartUpload(AbortMultipartUploadRequest(
            bucket: request.bucket,
            key: request.key,
            uploadId: checkpoint?.info.data.uploadInfo?.uploadId
        ))
        try checkpoint?.remove()
    }
    
    private func singlePart() async throws -> UploadResult {
        let result = try await client.putObject(
            PutObjectRequest(
                bucket: request.bucket,
                key: request.key,
                body: request.body,
                progress: request.progress
            )
        )
        return UploadResult(
            commonProp: result.commonProp,
            uploadId: nil,
            eTag: result.etag,
            versionId: result.versionId,
            hashCRC64: result.hashCrc64ecma
        )
    }
    
    private func multiPart() async throws -> UploadResult {
        let request = self.request
        let partSize = self.partSize
        
        var partCount = Int(totalSize / UInt64(partSize))
        if totalSize % UInt64(partSize) > 0 { partCount += 1}

        let enableCRC = client.clientImpl.options.featureFlags.contains(.enableCRC64CheckUpload)
        
        let uploadId: String
        let transferredInfo: TransferredInfo
        if let _uploadId = checkpoint?.info.data.uploadInfo?.uploadId {
            transferredInfo = try await adjustSource(uploadId: _uploadId) ?? TransferredInfo()
            uploadId = _uploadId
        } else {
            transferredInfo = TransferredInfo()
            uploadId = try await getUploadId()
            if var checkpoint = checkpoint {
                checkpoint.info.data.uploadInfo = UploadCheckpoint.Info.Data.UploadInfo(uploadId: uploadId)
                try checkpoint.dump()
            }
        }
        
        if await transferredInfo.transferred != 0 {
            await self.processProgress(transferredInfo.transferred)
        }
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                var uploadedPartIterator = await transferredInfo.parts.makeIterator()
                var uploadedPart = uploadedPartIterator.next()
                
                var uploadCount = 0
                for partNumber in 1...partCount {
                    if uploadedPart?.uploadPart.partNumber == partNumber {
                        uploadedPart = uploadedPartIterator.next()
                        continue
                    }
                    
                    uploadCount += 1
                    if uploadCount > options.parallelNum { try await group.next() }
                    let _ = group.addTaskUnlessCancelled {
                        guard let data = try request.body?.readData(
                            UInt64((partNumber - 1) * partSize),
                            partSize
                        ) else {
                            throw ClientError.fileOperationError(filePath: "", operation: "Read data fail.")
                        }
                        
                        let result = try await self.client.uploadPart(
                            UploadPartRequest(
                                bucket: request.bucket,
                                key: request.key,
                                partNumber: partNumber,
                                uploadId: uploadId,
                                body: .data(data)
                            )
                        )
                        let part =  UploadPart(
                            etag: result.etag,
                            partNumber: partNumber
                        )
                        
                        let crcValue = enableCRC ? result.commonProp.headers?[caseInsensitive: "x-oss-hash-crc64ecma"]?.toUInt64() : nil
                        await transferredInfo.transferred(
                            UploadPartCRC(
                                uploadPart: part,
                                crcValue: crcValue,
                                size: data.count
                            )
                        )
                        
                        await self.processProgress(Int64(data.count))
                    }
                }
                
                try await group.waitForAll()
            }
            try Task.checkCancellation()
            
            let sortedParts = await transferredInfo.parts.sorted {
                $0.uploadPart.partNumber! < $1.uploadPart.partNumber!
            }
            let parts = sortedParts.map { $0.uploadPart }
            let completeResult = try await client.completeMultipartUpload(
                CompleteMultipartUploadRequest(
                    bucket: request.bucket,
                    key: request.key,
                    uploadId: uploadId,
                    completeMultipartUpload: CompleteMultipartUpload(parts: parts)
                )
            )
            
            if enableCRC {
                let clientCRCValue = sortedParts.reduce(0) {
                    CRC64.default.crc64Combine(crc1: $0, crc2: $1.crcValue ?? 0, len2: UInt($1.size))
                }
                if let serverCRCValue = completeResult.commonProp.headers?[caseInsensitive: "x-oss-hash-crc64ecma"]?.toUInt64(),
                   clientCRCValue != serverCRCValue {
                    throw ClientError.inconsistentError(clientCrc: clientCRCValue, serverCrc: serverCRCValue)
                }
            }
            try checkpoint?.remove()
            
            return UploadResult(
                commonProp: completeResult.commonProp,
                uploadId: uploadId,
                eTag: completeResult.etag,
                versionId: completeResult.versionId,
                hashCRC64: completeResult.commonProp.headers?[caseInsensitive: "x-oss-hash-crc64ecma"]?.toUInt64()
            )
        } catch {
            print("\(error)")
            if !options.leavePartsOnError {
                let _ = try await client.abortMultipartUpload(
                    AbortMultipartUploadRequest(
                        bucket: request.bucket,
                        key: request.key,
                        uploadId: uploadId
                    )
                )
            }
            throw error
        }
    }
    
    private func processProgress(_ transferred: Int64) {
        var progress = request.progress

        self.totalBytesTransferred += transferred
        progress?.onProgress(transferred, self.totalBytesTransferred, Int64(self.totalSize))
    }
}

struct UploadCheckpoint {

    struct Info: Codable {
        
        struct Data: Codable {
            struct FileMeta: Codable, Equatable {
                let size: UInt64
                let lastModified: String
                
                static func == (lhs: Self, rhs: Self) -> Bool {
                    lhs.size == rhs.size &&
                    lhs.lastModified == rhs.lastModified
                }
            }
            
            struct ObjectInfo: Codable, Equatable {
                let objectKey: String
                
                static func == (lhs: Self, rhs: Self) -> Bool {
                    lhs.objectKey == rhs.objectKey
                }
            }
            
            struct UploadInfo: Codable, Equatable {
                let uploadId: String
                
                static func == (lhs: Self, rhs: Self) -> Bool {
                    lhs.uploadId == rhs.uploadId
                }
            }
            
            let partSize: Int
            
            let fileMeta: FileMeta
            let objectInfo: ObjectInfo
            var uploadInfo: UploadInfo?
        }
        
        let magic: String
        var md5: String?
        
        var data: Data
    }
    
    let cpDirPath: String
    let cpFilePath: String
    var loaded: Bool
    
    var info: Info
    
    mutating func load() throws {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: cpDirPath, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return
        }
        
        isDirectory = false
        guard FileManager.default.fileExists(atPath: cpFilePath, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            return
        }
        
        if try !valid() {
            try remove()
        }
        
        loaded = true
    }
    
    mutating func valid() throws -> Bool {
        let content = try Data(contentsOf: URL(fileURLWithPath: cpFilePath))
        
        let info = try JSONDecoder().decode(UploadCheckpoint.Info.self, from: content)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(info.data)
        let md5 = data.calculateMd5().hexString()
        guard info.magic == Defaults.checkpointMagic,
              md5 == info.md5 else {
            return false
        }
        
        guard info.data.objectInfo == self.info.data.objectInfo,
              info.data.fileMeta == self.info.data.fileMeta,
              info.data.partSize == self.info.data.partSize else {
            return false
        }
        
        if info.data.uploadInfo?.uploadId.count == 0 {
            return false
        }
        self.info.data.uploadInfo = info.data.uploadInfo

        return true
    }
    
    func dump() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(info.data)
        let md5 = data.calculateMd5().hexString()
        var info = self.info
        info.md5 = md5
        
        let content = try JSONEncoder().encode(info)
        try content.write(to: URL(fileURLWithPath: cpFilePath), options: .atomic)
    }
    
    func remove() throws {
        try FileManager.default.removeItem(atPath: cpFilePath)
    }
}

extension ByteStream {
    func readData(_ offset: UInt64 = 0, _ size: Int = 0) throws -> Data? {
        switch self {
        case .none:
            return nil
        case let .data(data):
            return data.subdata(in: Int(offset)..<Int(offset) + size)
        case let .file(fileURL):
            do {
                let fileHandle = try FileHandle(forReadingFrom: fileURL)
                defer {//33490afedc4b6d4d400228331f668197
                    fileHandle.closeFile()
                }
                try fileHandle.seek(toOffset: offset)
                if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
                    return try fileHandle.read(upToCount: size)
                } else {
                    return fileHandle.readData(ofLength: size)
                }
            } catch {
                throw ClientError.operationError(name: "Open file", innerError: error)
            }
        case .stream(_):
            throw _Error.streamForBodyNotSuportedRead
        }
    }
}
