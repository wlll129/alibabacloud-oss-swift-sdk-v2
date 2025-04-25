import Foundation

public class Client: @unchecked Sendable {
    var clientImpl: ClientImpl

    public init(
        _ config: Configuration,
        _ actions: ClientOptionsAction...
    ) {
        clientImpl = ClientImpl(config, actions.map { $0 })
    }

    public func invokeOperation(
        _ input: OperationInput,
        _ options: OperationOptions? = nil
    ) async throws -> OperationOutput {
        var input_ = input
        return try await clientImpl.execute(with: &input_, args: options)
    }
}
