import Foundation

// MARK: - PutBucketVersioning

extension Serde {
    static func serializePutBucketVersioning(
        _ request: inout PutBucketVersioningRequest,
        _ input: inout OperationInput
    ) throws {
        var xmlBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        xmlBody.append("<VersioningConfiguration>")
        if let status = request.versioningConfiguration?.status {
            xmlBody.append("<Status>\(status)</Status>")
        }
        xmlBody.append("</VersioningConfiguration>")

        input.body = .data(xmlBody.data(using: .utf8)!)
    }

    static func deserializePutBucketVersioning(
        _: inout PutBucketVersioningResult,
        _: inout OperationOutput
    ) throws {}
}

// MARK: - GetBucketVersioning

extension Serde {
    static func serializeGetBucketVersioning(
        _: inout GetBucketVersioningRequest,
        _: inout OperationInput
    ) throws {}

    static func deserializeGetBucketVersioning(
        _ result: inout GetBucketVersioningResult,
        _ output: inout OperationOutput
    ) throws {
        let body = try Serde.deserializeXml(output.body)

        if let config = body["VersioningConfiguration"] as? [String: String] {
            let versioningConfiguration = VersioningConfiguration(status: config["Status"])
            result.versioningConfiguration = versioningConfiguration
        }
    }
}

// MARK: - ListObjectVersions

extension Serde {
    static func serializeListObjectVersions(
        _ request: inout ListObjectVersionsRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.delimiter {
            input.parameters["delimiter"] = value
        }

        if let value = request.keyMarker {
            input.parameters["key-marker"] = value
        }

        if let value = request.versionIdMarker {
            input.parameters["version-id-marker"] = value
        }

        if let value = request.maxKeys {
            input.parameters["max-keys"] = String(value)
        }

        if let value = request.prefix {
            input.parameters["prefix"] = value
        }

        if let value = request.encodingType {
            input.parameters["encoding-type"] = value
        }
    }

    static func deserializeListObjectVersions(
        _ result: inout ListObjectVersionsResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "ListVersionsResult")

        result.name = body["Name"] as? String
        result.prefix = body["Prefix"] as? String
        result.keyMarker = body["KeyMarker"] as? String
        result.nextKeyMarker = body["NextKeyMarker"] as? String
        result.versionIdMarker = body["VersionIdMarker"] as? String
        result.nextVersionIdMarker = body["NextVersionIdMarker"] as? String
        result.encodingType = body["EncodingType"] as? String
        result.delimiter = body["Delimiter"] as? String
        result.maxKeys = (body["MaxKeys"] as? String)?.toInt()
        result.isTruncated = (body["IsTruncated"] as? String)?.toBool()

        // CommonPrefixes
        var commonPrefixes: [CommonPrefix]?
        if let commonPrefix = body["CommonPrefixes"] as? [String: String],
           let prefix = commonPrefix["Prefix"]
        {
            commonPrefixes = [CommonPrefix(prefix: prefix)]
        } else if let commonPrefix = body["CommonPrefixes"] as? [[String: String]] {
            commonPrefixes = []
            for prefix in commonPrefix {
                if let _prefix = prefix["Prefix"] {
                    commonPrefixes?.append(CommonPrefix(prefix: _prefix))
                }
            }
        }
        result.commonPrefixes = commonPrefixes

        // version
        if let contents = body["Version"] {
            var objectVersions: [ObjectVersion] = []

            var versions: [[String: Any]] = []
            if let _contents = contents as? [[String: Any]] {
                versions.append(contentsOf: _contents)
            } else if let content = contents as? [String: Any] {
                versions.append(content)
            }
            for version in versions {
                var objectVersion = ObjectVersion()
                objectVersion.key = version["Key"] as? String
                objectVersion.versionId = version["VersionId"] as? String
                objectVersion.eTag = version["ETag"] as? String
                objectVersion.restoreInfo = version["RestoreInfo"] as? String
                objectVersion.storageClass = version["StorageClass"] as? String
                objectVersion.size = (version["Size"] as? String)?.toInt()
                objectVersion.lastModified = (version["LastModified"] as? String)?.toDate()
                objectVersion.transitionTime = (version["TransitionTime"] as? String)?.toDate()
                objectVersion.isLatest = (version["IsLatest"] as? String)?.toBool()
                if let ownerData = version["Owner"] as? [String: String] {
                    var owner = Owner()
                    owner.displayName = ownerData["DisplayName"]
                    owner.id = ownerData["ID"]
                    objectVersion.owner = owner
                }

                objectVersions.append(objectVersion)
            }
            result.versions = objectVersions
        }

        // deleteMarker
        if let contents = body["DeleteMarker"] {
            var deleteMarkers: [DeleteMarkerEntry] = []

            var markers: [[String: Any]] = []
            if let _contents = contents as? [[String: Any]] {
                markers.append(contentsOf: _contents)
            } else if let content = contents as? [String: Any] {
                markers.append(content)
            }
            for marker in markers {
                var deleteMarker = DeleteMarkerEntry()
                deleteMarker.key = marker["Key"] as? String
                deleteMarker.versionId = marker["VersionId"] as? String
                deleteMarker.lastModified = (marker["LastModified"] as? String)?.toDate()
                deleteMarker.isLatest = (marker["IsLatest"] as? String)?.toBool()
                if let ownerData = marker["Owner"] as? [String: String] {
                    var owner = Owner()
                    owner.displayName = ownerData["DisplayName"]
                    owner.id = ownerData["ID"]
                    deleteMarker.owner = owner
                }

                deleteMarkers.append(deleteMarker)
            }
            result.deleteMarkers = deleteMarkers
        }

        deserializeEncodingType(result: &result)
    }

    static func deserializeEncodingType(result: inout ListObjectVersionsResult) {
        guard result.encodingType == "url" else {
            return
        }

        result.prefix = result.prefix?.removingPercentEncoding
        result.delimiter = result.delimiter?.removingPercentEncoding
        result.nextKeyMarker = result.nextKeyMarker?.removingPercentEncoding
        result.keyMarker = result.keyMarker?.removingPercentEncoding
        if let versions = result.versions {
            var decodeVersions: [ObjectVersion] = []
            for version in versions {
                var decodeVersion = version
                decodeVersion.key = decodeVersion.key?.removingPercentEncoding
                decodeVersions.append(decodeVersion)
            }
            result.versions = decodeVersions
        }
        if let deleteMarkers = result.deleteMarkers {
            var decodeDeleteMarkers: [DeleteMarkerEntry] = []
            for deleteMarker in deleteMarkers {
                var decodeDeleteMarker = deleteMarker
                decodeDeleteMarker.key = decodeDeleteMarker.key?.removingPercentEncoding
                decodeDeleteMarkers.append(decodeDeleteMarker)
            }
            result.deleteMarkers = decodeDeleteMarkers
        }
        if let commonPrefixes = result.commonPrefixes {
            var decodeCommonPrefixes: [CommonPrefix] = []
            for commonPrefix in commonPrefixes {
                var decodeCommonPrefix = commonPrefix
                decodeCommonPrefix.prefix = decodeCommonPrefix.prefix?.removingPercentEncoding
                decodeCommonPrefixes.append(decodeCommonPrefix)
            }
            result.commonPrefixes = decodeCommonPrefixes
        }
    }
}
