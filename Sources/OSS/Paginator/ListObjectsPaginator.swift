import Foundation

public struct ListObjectsPaginator: AsyncSequence {
    public typealias Element = ListObjectsResult

    let client: Client
    let request: ListObjectsRequest

    public init(
        client: Client,
        request: ListObjectsRequest,
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
        let sequence: ListObjectsPaginator
        var request: ListObjectsRequest?

        init(sequence: ListObjectsPaginator) {
            self.sequence = sequence
            request = sequence.request
        }

        public mutating func next() async throws -> ListObjectsResult? {
            if let request = request {
                let result = try await sequence.client.listObjects(request)
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
