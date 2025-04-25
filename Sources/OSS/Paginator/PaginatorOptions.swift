public struct PaginatorOptions {
    /// The maximum number of items in the response.
    public var limit: Swift.Int?

    public init(
        limit: Swift.Int? = nil
    ) {
        self.limit = limit
    }
}
