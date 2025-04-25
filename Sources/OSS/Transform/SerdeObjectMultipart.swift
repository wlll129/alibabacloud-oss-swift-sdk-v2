import Foundation

// MARK: - InitiateMultipartUpload

extension Serde {
    static func serializeInitiateMultipartUpload(
        _ request: inout InitiateMultipartUploadRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.forbidOverwrite {
            input.headers["x-oss-forbid-overwrite"] = value.toString()
        }

        if let value = request.storageClass {
            input.headers["x-oss-storage-class"] = value
        }

        if let value = request.tagging {
            input.headers["x-oss-tagging"] = value
        }

        if let value = request.serverSideEncryption {
            input.headers["x-oss-server-side-encryption"] = value
        }

        if let value = request.serverSideDataEncryption {
            input.headers["x-oss-server-side-data-encryption"] = value
        }

        if let value = request.serverSideEncryptionKeyId {
            input.headers["x-oss-server-side-encryption-key-id"] = value
        }

        if let value = request.cacheControl {
            input.headers["Cache-Control"] = value
        }

        if let value = request.contentDisposition {
            input.headers["Content-Disposition"] = value
        }

        if let value = request.contentEncoding {
            input.headers["Content-Encoding"] = value
        }

        if let value = request.expires {
            input.headers["Expires"] = value
        }

        if let value = request.encodingType {
            input.parameters["encoding-type"] = value
        }
    }

    static func deserializeInitiateMultipartUpload(
        _ result: inout InitiateMultipartUploadResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: String] = try Serde.deserializeXml(output.body, "InitiateMultipartUploadResult")
        result.uploadId = body["UploadId"]
        result.bucket = body["Bucket"]
        result.key = body["Key"]
        result.encodingType = body["EncodingType"]

        deserializeInitiateMultipartUploadEncodingType(result: &result)
    }

    static func deserializeInitiateMultipartUploadEncodingType(result: inout InitiateMultipartUploadResult) {
        if result.encodingType == "url" {
            result.key = result.key?.removingPercentEncoding
        }
    }
}

// MARK: - UploadPart

extension Serde {
    static func serializeUploadPart(
        _ request: inout UploadPartRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.partNumber {
            input.parameters["partNumber"] = String(value)
        }

        if let value = request.uploadId {
            input.parameters["uploadId"] = value
        }

        input.body = request.body
    }

    static func deserializeUploadPart(
        _: inout UploadPartResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - CompleteMultipartUpload

extension Serde {
    static func serializeCompleteMultipartUpload(
        _ request: inout CompleteMultipartUploadRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.forbidOverwrite {
            input.headers["x-oss-forbid-overwrite"] = value.toString()
        }

        if let value = request.completeAll {
            input.headers["x-oss-complete-all"] = value
        }

        if let value = request.uploadId {
            input.parameters["uploadId"] = value
        }

        if let value = request.encodingType {
            input.parameters["encoding-type"] = value
        }

        if let parts = request.completeMultipartUpload?.parts {
            var xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            xmlBody.append("<CompleteMultipartUpload>")
            for part in parts {
                if let partNumber = part.partNumber,
                   let etag = part.etag
                {
                    xmlBody.append("<Part>")
                    xmlBody.append("<PartNumber>\(partNumber)</PartNumber>")
                    xmlBody.append("<ETag>\(etag)</ETag>")
                    xmlBody.append("</Part>")
                }
            }
            xmlBody.append("</CompleteMultipartUpload>")
            input.body = .data(xmlBody.data(using: .utf8)!)
        }
    }

    static func deserializeCompleteMultipartUpload(
        _ result: inout CompleteMultipartUploadResult,
        _ output: inout OperationOutput
    ) throws {
        if let callbackResult = output.headers["x-oss-callback"] {
            result.callbackResult = Data(base64Encoded: callbackResult)
        } else {
            let body: [String: String] = try Serde.deserializeXml(output.body, "CompleteMultipartUploadResult")
            result.bucket = body["Bucket"]
            result.key = body["Key"]
            result.etag = body["ETag"]
            result.location = body["Location"]
            result.encodingType = body["EncodingType"]

            if result.encodingType == "url" {
                result.key = result.key?.removingPercentEncoding
            }
        }
    }
}

// MARK: - UploadPartCopy

extension Serde {
    static func serializeUploadPartCopy(
        _ request: inout UploadPartCopyRequest,
        _ input: inout OperationInput
    ) throws {
        if let sourceBucket = request.sourceBucket,
           let sourceKey = request.sourceKey
        {
            input.headers["x-oss-copy-source"] = "/\(sourceBucket)/\(sourceKey)"
        }

        if let value = request.copySourceRange {
            input.headers["x-oss-copy-source-range"] = value
        }

        if let value = request.copySourceIfMatch {
            input.headers["x-oss-copy-source-if-match"] = value
        }

        if let value = request.copySourceIfNoneMatch {
            input.headers["x-oss-copy-source-if-none-match"] = value
        }

        if let value = request.copySourceIfUnmodifiedSince {
            input.headers["x-oss-copy-source-if-unmodified-since"] = value
        }

        if let value = request.copySourceIfModifiedSince {
            input.headers["x-oss-copy-source-if-modified-since"] = value
        }

        if let value = request.partNumber {
            input.parameters["partNumber"] = String(value)
        }

        if let value = request.uploadId {
            input.parameters["uploadId"] = value
        }
    }

    static func deserializeUploadPartCopy(
        _ result: inout UploadPartCopyResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: String] = try Serde.deserializeXml(output.body, "CopyPartResult")

        var copyPartResult = CopyPartResult(etag: body["ETag"])
        copyPartResult.lastModified = body["LastModified"]?.toDate()
        result.copyPartResult = copyPartResult
    }
}

// MARK: - AbortMultipartUpload

extension Serde {
    static func serializeAbortMultipartUpload(
        _ request: inout AbortMultipartUploadRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.uploadId {
            input.parameters["uploadId"] = value
        }
    }

    static func deserializeAbortMultipartUpload(
        _: inout AbortMultipartUploadResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - ListMultipartUploads

extension Serde {
    static func serializeListMultipartUploads(
        _ request: inout ListMultipartUploadsRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.delimiter {
            input.parameters["delimiter"] = value
        }

        if let value = request.maxUploads {
            input.parameters["max-uploads"] = String(value)
        }

        if let value = request.keyMarker {
            input.parameters["key-marker"] = value
        }

        if let value = request.prefix {
            input.parameters["prefix"] = value
        }

        if let value = request.uploadIdMarker {
            input.parameters["upload-id-marker"] = value
        }

        if let value = request.encodingType {
            input.parameters["encoding-type"] = value
        }
    }

    static func deserializeListMultipartUploads(
        _ result: inout ListMultipartUploadsResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "ListMultipartUploadsResult")

        result.isTruncated = (body["IsTruncated"] as? String)?.toBool()
        result.bucket = body["Bucket"] as? String
        result.keyMarker = body["KeyMarker"] as? String
        result.uploadIdMarker = body["UploadIdMarker"] as? String
        result.nextKeyMarker = body["NextKeyMarker"] as? String
        result.nextUploadIdMarker = body["NextUploadIdMarker"] as? String
        result.delimiter = body["Delimiter"] as? String
        result.prefix = body["Prefix"] as? String
        result.encodingType = body["EncodingType"] as? String
        result.maxUploads = (body["MaxUploads"] as? String)?.toInt()
        if let commonPrefixe = body["CommonPrefixes"] as? [String: String] {
            var commonPrefixes: [CommonPrefix] = []
            if let prefix = commonPrefixe["Prefix"] {
                commonPrefixes.append(CommonPrefix(prefix: prefix))
            }
            result.commonPrefixes = commonPrefixes
        } else if let commonPrefixe = body["CommonPrefixes"] as? [[String: String]] {
            var commonPrefixes: [CommonPrefix] = []
            for element in commonPrefixe {
                if let prefix = element["Prefix"] {
                    commonPrefixes.append(CommonPrefix(prefix: prefix))
                }
            }
            result.commonPrefixes = commonPrefixes
        }

        var uploads: [Upload] = []
        if let uploadElement = body["Upload"] as? [String: String] {
            if let key = uploadElement["Key"],
               let uploadId = uploadElement["UploadId"]
            {
                let initiated = uploadElement["Initiated"]?.toDate()
                let upload = Upload(initiated: initiated,
                                    key: key,
                                    uploadId: uploadId)
                uploads.append(upload)
            }
        } else if let uploadElements = body["Upload"] as? [[String: String]] {
            for element in uploadElements {
                if let key = element["Key"],
                   let uploadId = element["UploadId"]
                {
                    let initiated = element["Initiated"]?.toDate()
                    let upload = Upload(initiated: initiated,
                                        key: key,
                                        uploadId: uploadId)
                    uploads.append(upload)
                }
            }
        }
        result.uploads = uploads

        deserializeListMultipartUploadsEncodingType(result: &result)
    }

    static func deserializeListMultipartUploadsEncodingType(result: inout ListMultipartUploadsResult) {
        if result.encodingType == "url" {
            result.prefix = result.prefix?.removingPercentEncoding
            result.keyMarker = result.keyMarker?.removingPercentEncoding
            result.nextKeyMarker = result.nextKeyMarker?.removingPercentEncoding
            result.delimiter = result.delimiter?.removingPercentEncoding
            if let uploads = result.uploads {
                var decodedUploads: [Upload] = []
                for upload in uploads {
                    var decodedUpload = upload
                    decodedUpload.key = decodedUpload.key?.removingPercentEncoding
                    decodedUploads.append(decodedUpload)
                }
                result.uploads = decodedUploads
            }
        }
    }
}

// MARK: - ListParts

extension Serde {
    static func serializeListParts(
        _ request: inout ListPartsRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.uploadId {
            input.parameters["uploadId"] = value
        }

        if let value = request.maxParts {
            input.parameters["max-parts"] = String(value)
        }

        if let value = request.partNumberMarker {
            input.parameters["part-number-marker"] = String(value)
        }

        if let value = request.encodingType {
            input.parameters["encoding-type"] = value
        }
    }

    static func deserializeListParts(
        _ result: inout ListPartsResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "ListPartsResult")

        result.bucket = body["Bucket"] as? String
        result.key = body["Key"] as? String
        result.uploadId = body["UploadId"] as? String
        result.encodingType = body["EncodingType"] as? String
        result.isTruncated = (body["IsTruncated"] as? String)?.toBool()
        result.partNumberMarker = (body["PartNumberMarker"] as? String)?.toInt()
        result.nextPartNumberMarker = (body["NextPartNumberMarker"] as? String)?.toInt()
        result.maxParts = (body["MaxParts"] as? String)?.toInt()

        var parts: [Part] = []
        if let partElement = body["Part"] as? [String: String] {
            var part = Part()
            part.etag = partElement["ETag"]
            part.hashCrc64 = partElement["HashCrc64"]
            part.partNumber = partElement["PartNumber"]?.toInt()
            part.size = partElement["Size"]?.toInt()
            part.lastModified = partElement["LastModified"]?.toDate()
            parts.append(part)
        } else if let partElements = body["Part"] as? [[String: String]] {
            for element in partElements {
                var part = Part()
                part.etag = element["ETag"]
                part.hashCrc64 = element["HashCrc64"]
                part.partNumber = element["PartNumber"]?.toInt()
                part.size = element["Size"]?.toInt()
                part.lastModified = element["LastModified"]?.toDate()
                parts.append(part)
            }
        }
        result.parts = parts

        if result.encodingType == "url" {
            result.key = result.key?.removingPercentEncoding
        }
    }
}
