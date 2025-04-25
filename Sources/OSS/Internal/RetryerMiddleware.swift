import Foundation

protocol RetryHandler {
    func retrying(request: RequestMessage, context: ExecuteContext, error: Error)
}

struct FixTimeRetryHandler: RetryHandler {
    func retrying(request _: RequestMessage, context: ExecuteContext, error: Error) {
        // fix time
        guard let serverError = error as? ServerError else {
            return
        }
        if serverError.code == "RequestTimeTooSkewed" ||
            (serverError.code == "InvalidArgument" &&
                serverError.message == "Invalid signing date in Authorization header.")
        {
            if let time = serverError.errorFields["ServerTime"] {
                let data = DateFormatter.iso8601DateTimeSeconds.date(from: time)
                context.signingContext?.clockOffset = data?.timeIntervalSince(Date())
            } else if let time = serverError.headers[caseInsensitive: "Date"] {
                let data = DateFormatter.rfc5322DateTime.date(from: time)
                context.signingContext?.clockOffset = data?.timeIntervalSince(Date())
            }
        }
    }
}

class RetryerMiddleware: ExecuteMiddleware {
    let nextHandler: ExecuteMiddleware
    let retryer: Retryer
    let maxAttempts: Int
    let logger: LogAgent?
    let retryHandler: RetryHandler?

    init(nextHandler: ExecuteMiddleware,
         retryer: Retryer,
         logger: LogAgent? = nil,
         retryHandler: RetryHandler? = nil)
    {
        self.nextHandler = nextHandler
        self.retryer = retryer
        maxAttempts = max(self.retryer.maxAttempts(), 1)
        self.logger = logger
        self.retryHandler = retryHandler
    }

    public func execute(request: RequestMessage, context: ExecuteContext) async throws -> ResponseMessage {
        var attempt = 0
        while true {
            do {
                try Task.checkCancellation()
                return try await nextHandler.execute(request: request, context: context)
            } catch {
                attempt += 1
                if attempt >= maxAttempts {
                    throw error
                }

                if let isSeekable = request.content?.isSeekable, !isSeekable {
                    throw error
                }

                let retry = retryer.isErrorRetryable(error: error)

                if !retry {
                    throw error
                }

                let delay = retryer.retryDelay(attempt: attempt, error: error)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                retryHandler?.retrying(request: request, context: context, error: error)

                logger?.debug("Should retry. Current attempt: \(attempt), delay: \(delay), error: \(error.localizedDescription)")
            }
        }
    }
}
