
/// A paginator for ListBuckets
public struct ListBucketsPaginator: AsyncSequence {
    public typealias Element = ListBucketsResult

    let client: Client
    let request: ListBucketsRequest

    public init(
        client: Client,
        request: ListBucketsRequest,
        options: PaginatorOptions? = nil
    ) {
        var request = request
        if let limit = options?.limit {
            request.maxKeys = limit
        }
        self.client = client
        self.request = request
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let sequence: ListBucketsPaginator
        var request: ListBucketsRequest?

        init(sequence: ListBucketsPaginator) {
            self.sequence = sequence
            request = sequence.request
        }

        public mutating func next() async throws -> ListBucketsResult? {
            if let request = request {
                let result = try await sequence.client.listBuckets(request)
                // has next page
                if result.isTruncated ?? false {
                    self.request?.marker = result.nextMarker
                } else {
                    self.request = nil
                }
                return result
            }
            return nil
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(sequence: self)
    }
}
