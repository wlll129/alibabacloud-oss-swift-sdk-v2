
protocol ExecuteMiddleware {
    func execute(request: RequestMessage, context: ExecuteContext) async throws -> ResponseMessage
}
