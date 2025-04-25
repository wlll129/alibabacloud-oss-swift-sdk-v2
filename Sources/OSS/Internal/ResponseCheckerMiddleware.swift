import Foundation

class ResponseCheckerMiddleware: ExecuteMiddleware {
    let nextHandler: ExecuteMiddleware
    let logger: LogAgent?

    init(nextHandler: ExecuteMiddleware,
         logger: LogAgent? = nil)
    {
        self.nextHandler = nextHandler
        self.logger = logger
    }

    public func execute(request: RequestMessage, context: ExecuteContext) async throws -> ResponseMessage {
        let response = try await nextHandler.execute(request: request, context: context)

        if let handlers = context.responseHandlers {
            for handler in handlers {
                logger?.debug("Should call handler: \(handler)")
                try handler.onResponse(request: request, response: response)
            }
        }

        return response
    }
}
