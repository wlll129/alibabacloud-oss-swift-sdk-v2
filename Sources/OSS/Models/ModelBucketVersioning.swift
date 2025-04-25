import Foundation

/// specifies the encoding method to use
public enum EncodeType: String {
    case url
}

/// The container that stores the versioning state of the bucket.
public struct VersioningConfiguration: Sendable {
    /// The versioning state of the bucket.
    /// Sees BucketVersioningStatusType for supported values.
    public var status: Swift.String?

    public init(
        status: Swift.String? = nil
    ) {
        self.status = status
    }
}

extension VersioningConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}

/// The container that stores delete markers.
public struct DeleteMarkerEntry {
    /// The time when the object was last modified.
    public var lastModified: Date?

    /// The container that stores the information about the bucket owner.
    public var owner: Owner?

    /// The name of the object.
    public var key: Swift.String?

    /// The version ID of the object.
    public var versionId: Swift.String?

    /// Indicates whether the version is the current version. Valid values:*   true: The version is the current version.*   false: The version is a previous version.
    public var isLatest: Swift.Bool?

    public init(
        lastModified: Date? = nil,
        owner: Owner? = nil,
        key: Swift.String? = nil,
        versionId: Swift.String? = nil,
        isLatest: Swift.Bool? = nil
    ) {
        self.lastModified = lastModified
        self.owner = owner
        self.key = key
        self.versionId = versionId
        self.isLatest = isLatest
    }
}

extension DeleteMarkerEntry: Codable {
    enum CodingKeys: String, CodingKey {
        case lastModified = "LastModified"
        case owner = "Owner"
        case key = "Key"
        case versionId = "VersionId"
        case isLatest = "IsLatest"
    }
}

/// The container that stores the versions of objects, excluding delete markers.
public struct ObjectVersion {
    /// The name of the object.
    public var key: Swift.String?

    /// Indicates whether the version is the current version. Valid values:*   true: The version is the current version.*   false: The version is a previous version.
    public var isLatest: Swift.Bool?

    /// The storage class of the object.
    /// Sees StorageClassType for supported values.
    public var storageClass: Swift.String?

    /// The time when the Object version is transitioned to cold archive or deep cold archive storage class by the lifecycle.
    public var transitionTime: Date?

    /// The version ID of the object.
    public var versionId: Swift.String?

    /// The time when the object was last modified.
    public var lastModified: Date?

    /// The ETag that is generated when an object is created. ETags are used to identify the content of objects.*   If an object is created by calling the PutObject operation, the ETag of the object is the MD5 hash of the object content.*   If an object is created by using another method, the ETag is not the MD5 hash of the object content but a unique value that is calculated based on a specific rule.  The ETag of an object can be used only to check whether the object content is modified. However, we recommend that you use the MD5 hash of an object rather than the ETag of the object to verify data integrity.
    public var eTag: Swift.String?

    /// The size of the object. Unit: bytes.
    public var size: Swift.Int?

    /// The container that stores the information about the bucket owner.
    public var owner: Owner?

    /// Restore info of the object.
    public var restoreInfo: Swift.String?

    public init(
        key: Swift.String? = nil,
        isLatest: Swift.Bool? = nil,
        storageClass: Swift.String? = nil,
        transitionTime: Date? = nil,
        versionId: Swift.String? = nil,
        lastModified: Date? = nil,
        eTag: Swift.String? = nil,
        size: Swift.Int? = nil,
        owner: Owner? = nil,
        restoreInfo: Swift.String? = nil
    ) {
        self.key = key
        self.isLatest = isLatest
        self.storageClass = storageClass
        self.transitionTime = transitionTime
        self.versionId = versionId
        self.lastModified = lastModified
        self.eTag = eTag
        self.size = size
        self.owner = owner
        self.restoreInfo = restoreInfo
    }
}

extension ObjectVersion: Codable {
    enum CodingKeys: String, CodingKey {
        case key = "Key"
        case isLatest = "IsLatest"
        case storageClass = "StorageClass"
        case transitionTime = "TransitionTime"
        case versionId = "VersionId"
        case lastModified = "LastModified"
        case eTag = "ETag"
        case size = "Size"
        case owner = "Owner"
        case restoreInfo = "RestoreInfo"
    }
}

/// The request for the PutBucketVersioning operation.
public struct PutBucketVersioningRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    /// The container of the request body.
    public var versioningConfiguration: VersioningConfiguration?

    public init(
        bucket: Swift.String? = nil,
        versioningConfiguration: VersioningConfiguration? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.versioningConfiguration = versioningConfiguration
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the PutBucketVersioning operation.
public struct PutBucketVersioningResult: ResultModel {
    public var commonProp: ResultModelProp = .init()
}

/// The request for the GetBucketVersioning operation.
public struct GetBucketVersioningRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    public init(
        bucket: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the GetBucketVersioning operation.
public struct GetBucketVersioningResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// The container that stores the versioning state of the bucket.
    public var versioningConfiguration: VersioningConfiguration?
}

/// The request for the ListObjectVersions operation.
public struct ListObjectVersionsRequest: RequestModel {
    public var commonProp: RequestModelProp

    /// The name of the bucket.
    public var bucket: Swift.String?

    /// The character that is used to group objects by name. If you specify prefix and delimiter in the request, the response contains CommonPrefixes. The objects whose name contains the same string from the prefix to the next occurrence of the delimiter are grouped as a single result element in CommonPrefixes. If you specify prefix and set delimiter to a forward slash (/), only the objects in the directory are listed. The subdirectories in the directory are returned in CommonPrefixes. Objects and subdirectories in the subdirectories are not listed.By default, this parameter is left empty.
    public var delimiter: Swift.String?

    /// The name of the object after which the GetBucketVersions (ListObjectVersions) operation begins. If this parameter is specified, objects whose name is alphabetically after the value of key-marker are returned. Use key-marker and version-id-marker in combination. The value of key-marker must be less than 1,024 bytes in length.By default, this parameter is left empty.  You must also specify key-marker if you specify version-id-marker.
    public var keyMarker: Swift.String?

    /// The version ID of the object specified in key-marker after which the GetBucketVersions (ListObjectVersions) operation begins. The versions are returned from the latest version to the earliest version. If version-id-marker is not specified, the GetBucketVersions (ListObjectVersions) operation starts from the latest version of the object whose name is alphabetically after the value of key-marker by default.By default, this parameter is left empty.Valid values: version IDs.
    public var versionIdMarker: Swift.String?

    /// The maximum number of objects to be returned. If the number of returned objects exceeds the value of max-keys, the response contains `NextKeyMarker` and `NextVersionIdMarker`. Specify the values of `NextKeyMarker` and `NextVersionIdMarker` as the markers for the next request. Valid values: 1 to 999. Default value: 100.
    public var maxKeys: Swift.Int?

    /// The prefix that the names of returned objects must contain.*   The value of prefix must be less than 1,024 bytes in length.*   If you specify prefix, the names of the returned objects contain the prefix.If you set prefix to a directory name, the objects whose name starts with the prefix are listed. The returned objects consist of all objects and subdirectories in the directory.By default, this parameter is left empty.
    public var prefix: Swift.String?

    /// The encoding type of the content in the response. By default, this parameter is left empty. Set the value to URL.  The values of Delimiter, Marker, Prefix, NextMarker, and Key are UTF-8 encoded. If the value of Delimiter, Marker, Prefix, NextMarker, or Key contains a control character that is not supported by Extensible Markup Language (XML) 1.0, you can specify encoding-type to encode the value in the response.
    /// Sees EncodeType for supported values.
    public var encodingType: Swift.String?

    public init(
        bucket: Swift.String? = nil,
        delimiter: Swift.String? = nil,
        keyMarker: Swift.String? = nil,
        versionIdMarker: Swift.String? = nil,
        maxKeys: Swift.Int? = nil,
        prefix: Swift.String? = nil,
        encodingType: Swift.String? = nil,
        commonProp: RequestModelProp? = nil
    ) {
        self.bucket = bucket
        self.delimiter = delimiter
        self.keyMarker = keyMarker
        self.versionIdMarker = versionIdMarker
        self.maxKeys = maxKeys
        self.prefix = prefix
        self.encodingType = encodingType
        self.commonProp = commonProp ?? RequestModelProp()
    }
}

/// The result for the ListObjectVersions operation.
public struct ListObjectVersionsResult: ResultModel {
    public var commonProp: ResultModelProp = .init()

    /// If not all results are returned for the request, the NextKeyMarker parameter is included in the response to indicate the key-marker value of the next ListObjectVersions (GetBucketVersions) request.
    public var nextKeyMarker: Swift.String?

    /// If not all results are returned for the request, the NextVersionIdMarker parameter is included in the response to indicate the version-id-marker value of the next ListObjectVersions (GetBucketVersions) request.
    public var nextVersionIdMarker: Swift.String?

    /// The container that stores the versions of objects except for delete markers
    public var versions: [ObjectVersion]?

    /// The encoding type of the content in the response. If you specify encoding-type in the request, the values of Delimiter, Marker, Prefix, NextMarker, and Key are encoded in the response.
    public var encodingType: Swift.String?

    /// The bucket name
    public var name: Swift.String?

    /// The prefix contained in the names of the returned objects.
    public var prefix: Swift.String?

    /// Indicates the object from which the ListObjectVersions (GetBucketVersions) operation starts.
    public var keyMarker: Swift.String?

    /// The version from which the ListObjectVersions (GetBucketVersions) operation starts. This parameter is used together with KeyMarker.
    public var versionIdMarker: Swift.String?

    /// The maximum number of objects that can be returned in the response.
    public var maxKeys: Swift.Int?

    /// The character that is used to group objects by name. The objects whose names contain the same string from the prefix to the next occurrence of the delimiter are grouped as a single result parameter in CommonPrefixes.
    public var delimiter: Swift.String?

    /// Indicates whether the returned results are truncated.- true: indicates that not all results are returned for the request.- false: indicates that all results are returned for the request.
    public var isTruncated: Swift.Bool?

    /// The container that stores delete markers
    public var deleteMarkers: [DeleteMarkerEntry]?

    /// Objects whose names contain the same string that ranges from the prefix to the next occurrence of the delimiter are grouped as a single result element
    public var commonPrefixes: [CommonPrefix]?
}
