import Foundation

public struct ListPartsPaginator: AsyncSequence {
    public typealias Element = ListPartsResult

    let client: Client
    let request: ListPartsRequest

    public init(
        client: Client,
        request: ListPartsRequest,
        options: PaginatorOptions? = nil
    ) {
        var request = request
        if let limit = options?.limit {
            request.maxParts = limit
        }
        self.client = client
        self.request = request
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let sequence: ListPartsPaginator
        var request: ListPartsRequest?

        init(sequence: ListPartsPaginator) {
            self.sequence = sequence
            request = sequence.request
        }

        public mutating func next() async throws -> ListPartsResult? {
            if let request = request {
                let result = try await sequence.client.listParts(request)
                // has next page
                if result.isTruncated ?? false {
                    self.request?.partNumberMarker = result.nextPartNumberMarker
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
