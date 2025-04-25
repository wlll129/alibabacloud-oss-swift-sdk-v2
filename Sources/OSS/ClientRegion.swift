import Foundation

public extension Client {
    /// Queries the endpoints of all supported regions or the endpoints of a specific region.
    /// - Parameters:
    ///   - request: The request parameter to send
    ///   - request: Optional, operation options
    /// - Returns: The result instance.
    func describeRegions(
        _ request: DescribeRegionsRequest,
        _ options: OperationOptions? = nil
    ) async throws -> DescribeRegionsResult {
        var input = OperationInput(
            operationName: "DescribeRegions",
            method: "GET",
            parameters: [
                "regions": "",
            ]
        )

        var req = request

        try Serde.serializeInput(&req, &input, [Serde.serializeDescribeRegions, Serde.addContentMd5])

        var output = try await clientImpl.execute(with: &input, args: options)

        var result = DescribeRegionsResult()

        try Serde.deserializeOutput(&result, &output, [Serde.deserializeDescribeRegions])

        return result
    }
}
