import Foundation

class ExecuteContext {
    let retryMaxAttempts: Int?
    let readWriteTimeout: TimeInterval?
    var signingContext: SigningContext?
    var progressDelegate: ProgressDelegateDesc?
    let responseHandlers: [ResponseHandler]?
    let saveToURL: Bool?

    init(
        retryMaxAttempts: Int? = nil,
        readWriteTimeout: TimeInterval? = nil,
        signingContext: SigningContext? = nil,
        progressDelegate: ProgressDelegateDesc? = nil,
        responseHandlers: [ResponseHandler]? = nil,
        saveToURL: Bool? = nil
    ) {
        self.retryMaxAttempts = retryMaxAttempts
        self.readWriteTimeout = readWriteTimeout
        self.signingContext = signingContext
        self.progressDelegate = progressDelegate
        self.responseHandlers = responseHandlers
        self.saveToURL = saveToURL
    }
}
