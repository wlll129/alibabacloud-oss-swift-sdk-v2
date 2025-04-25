
public class RemoteSignerV4: SignerV4 {
    let delegate: SignatureDelegate

    public init(delegate: SignatureDelegate) {
        self.delegate = delegate
    }

    override public func sign(request: RequestMessage, signingContext: inout SigningContext) async throws -> RequestMessage {
        var request = request

        // setp 1
        if signingContext.authHeader {
            preAuthHeader(request: &request, context: &signingContext)
        } else {
            preAuthQuery(request: &request, context: &signingContext)
        }

        // setp 2 & 3
        let signInfo: [String: String] = [
            "version": "v4",

            // resource
            "method": request.method,
            "bucket": signingContext.bucket ?? "",
            "key": signingContext.key ?? "",

            // signing context
            "stringToSign": signingContext.stringToSign,
            "region": signingContext.region ?? "",
            "product": signingContext.product ?? "",
            "date": signingContext.dateToSign,
            "accessKeyId": signingContext.credentials!.accessKeyId,
        ]

        let signResult: [String: String]

        do {
            signResult = try await delegate.signature(info: signInfo)
        } catch {
            throw ClientError.signatureCallError(innerError: error)
        }

        // print("signResult:\n\(signResult)\n")

        guard let signature = signResult["signature"] else {
            throw ClientError.signatureResultRequiredError(field: "signature")
        }

        // setp 4
        if signingContext.authHeader {
            postAuthHeader(request: &request, context: &signingContext, signature: signature)
        } else {
            postAuthQuery(request: &request, context: &signingContext, signature: signature)
        }

        return request
    }
}
