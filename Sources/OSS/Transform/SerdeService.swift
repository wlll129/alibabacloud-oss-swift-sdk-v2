import Foundation

// MARK: - ListBuckets

extension Serde {
    static func serializeListBuckets(
        _ request: inout ListBucketsRequest,
        _ input: inout OperationInput
    ) throws {
        if let value = request.resourceGroupId {
            input.headers["x-oss-resource-group-id"] = value
        }

        if let value = request.prefix {
            input.parameters["prefix"] = value
        }

        if let value = request.marker {
            input.parameters["marker"] = value
        }

        if let value = request.maxKeys {
            input.parameters["max-keys"] = String(value)
        }
    }

    static func deserializeListBuckets(
        _ result: inout ListBucketsResult,
        _ output: inout OperationOutput
    ) throws {
        let body: [String: Any] = try Serde.deserializeXml(output.body, "ListAllMyBucketsResult")

        result.prefix = body["Prefix"] as? String
        result.marker = body["Marker"] as? String
        result.nextMarker = body["NextMarker"] as? String
        result.maxKeys = (body["MaxKeys"] as? String)?.toInt()
        result.isTruncated = (body["IsTruncated"] as? String)?.toBool()
        if let ownerData = body["Owner"] as? [String: String] {
            var owner = Owner()
            owner.displayName = ownerData["DisplayName"]
            owner.id = ownerData["ID"]
            result.owner = owner
        }

        if let bucketContents = body["Buckets"] as? [String: Any],
           let contents = bucketContents["Bucket"]
        {
            var buckets: [BucketSummary] = []

            var responseBuckets: [[String: Any]] = []
            if let _responseBuckets = contents as? [[String: Any]] {
                responseBuckets.append(contentsOf: _responseBuckets)
            } else if let content = contents as? [String: Any] {
                responseBuckets.append(content)
            }
            for responseBucket in responseBuckets {
                var bucket = BucketSummary()
                bucket.name = responseBucket["Name"] as? String
                bucket.location = responseBucket["Location"] as? String
                bucket.extranetEndpoint = responseBucket["ExtranetEndpoint"] as? String
                bucket.intranetEndpoint = responseBucket["IntranetEndpoint"] as? String
                bucket.region = responseBucket["Region"] as? String
                bucket.storageClass = responseBucket["StorageClass"] as? String
                bucket.creationDate = (responseBucket["CreationDate"] as? String)?.toDate()
                buckets.append(bucket)
            }
            result.buckets = buckets
        }
    }
}
