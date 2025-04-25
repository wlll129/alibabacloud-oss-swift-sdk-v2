import Foundation

public struct ListObjectsV2Paginator: AsyncSequence {
    public typealias Element = ListObjectsV2Result

    let client: Client
    let request: ListObjectsV2Request

    public init(
        client: Client,
        request: ListObjectsV2Request,
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
        let sequence: ListObjectsV2Paginator
        var request: ListObjectsV2Request?

        init(sequence: ListObjectsV2Paginator) {
            self.sequence = sequence
            request = sequence.request
        }

        public mutating func next() async throws -> ListObjectsV2Result? {
            if let request = request {
                let result = try await sequence.client.listObjectsV2(request)
                // has next page
                if result.isTruncated ?? false {
                    self.request?.continuationToken = result.nextContinuationToken
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
