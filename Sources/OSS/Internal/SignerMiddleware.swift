import Foundation

private struct NopCredentialsProvider: CredentialsProvider {
    let cred = Credentials(accessKeyId: "", accessKeySecret: "")
    public func getCredentials() async throws -> Credentials {
        return cred
    }
}

class SignerMiddleware: ExecuteMiddleware {
    let signer: Signer
    let nextHandler: ExecuteMiddleware
    let provider: CredentialsProvider
    private let logger: LogAgent?

    init(
        nextHandler: ExecuteMiddleware,
        signer: Signer,
        provider: CredentialsProvider?,
        logger: LogAgent? = nil
    ) {
        self.nextHandler = nextHandler
        self.signer = signer
        self.provider = provider ?? NopCredentialsProvider()
        self.logger = logger
    }

    public func execute(request: RequestMessage, context: ExecuteContext) async throws -> ResponseMessage {
        if provider is AnonymousCredentialsProvider {
            return try await nextHandler.execute(request: request, context: context)
        }

        let credentials: Credentials
        do {
            credentials = try await provider.getCredentials()
        } catch {
            throw ClientError.credentialsFetchError(innerError: error)
        }

        if credentials.isEmpty() {
            throw ClientError.credentialsEmptyError()
        }

        context.signingContext?.credentials = credentials
        let req = try await signer.sign(request: request, signingContext: &(context.signingContext!))

        logger?.info("stringToSign: \n\(context.signingContext!.stringToSign)")

        return try await nextHandler.execute(request: req, context: context)
    }
}
