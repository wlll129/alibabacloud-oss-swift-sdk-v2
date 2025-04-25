import Foundation

public struct ListMultipartUploadsPaginator: AsyncSequence {
    public typealias Element = ListMultipartUploadsResult

    let client: Client
    let request: ListMultipartUploadsRequest

    public init(
        client: Client,
        request: ListMultipartUploadsRequest,
        options: PaginatorOptions? = nil
    ) {
        var request = request
        if let limit = options?.limit {
            request.maxUploads = limit
        }
        self.client = client
        self.request = request
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let sequence: ListMultipartUploadsPaginator
        var request: ListMultipartUploadsRequest?

        init(sequence: ListMultipartUploadsPaginator) {
            self.sequence = sequence
            request = sequence.request
        }

        public mutating func next() async throws -> ListMultipartUploadsResult? {
            if let request = request {
                let result = try await sequence.client.listMultipartUploads(request)
                // has next page
                if result.isTruncated ?? false {
                    self.request?.uploadIdMarker = result.nextUploadIdMarker
                    self.request?.keyMarker = result.nextKeyMarker
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
