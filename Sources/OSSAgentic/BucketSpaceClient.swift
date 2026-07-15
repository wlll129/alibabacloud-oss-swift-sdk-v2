import AlibabaCloudOSS
import Foundation

/// A factory namespace for clients scoped to a BucketSpace.
public enum BucketSpaceClient {
    /// Creates a `Client` scoped to a BucketSpace. Every bucket passed to the returned
    /// client is rewritten to its physical form `{prefix}-{accountId}-{region}-bs-apsr`,
    /// so ordinary object operations transparently target the BucketSpace.
    public static func make(
        _ config: Configuration,
        _ actions: ClientOptionsAction...
    ) -> Client {
        return makeScopedClient(config, suffix: "-bs-apsr", actions)
    }
}

/// Builds a `Client` whose requests are rewritten to a physical `{bucket}-{accountId}-{region}{suffix}`
/// name and routed to the matching virtual-hosted host, without mutating the operation input.
func makeScopedClient(
    _ config: Configuration,
    suffix: String,
    _ extraActions: [ClientOptionsAction]
) -> Client {
    let accountId = config.accountId ?? ""
    let region = config.region ?? ""

    // Resolves the physical bucket name from an operation input, without mutating it.
    let buildName: (OperationInput) -> String = { input in
        guard let bucket = input.bucket else { return "" }
        return "\(bucket)-\(accountId)-\(region)\(suffix)"
    }

    // Prefix the User-Agent for agentic requests without permanently mutating the
    // caller's configuration: the value is read synchronously during construction.
    let originalUserAgent = config.userAgent
    if let existing = originalUserAgent, !existing.isEmpty {
        config.userAgent = "agentic-client/\(existing)"
    } else {
        config.userAgent = "agentic-client"
    }
    defer { config.userAgent = originalUserAgent }

    // Apply the agentic routing on top of the extraActions result so it always wins.
    let agenticAction: ClientOptionsAction = { opts in
        opts.bucketNameResolver = buildName
        // Route to the physical virtual-hosted host, reading the endpoint that
        // extraActions may have adjusted.
        if let endpoint = opts.endpoint, let scheme = endpoint.scheme {
            let authority = endpoint.hostPort()
            opts.endpointProvider = { input in
                let host = input.bucket != nil ? "\(buildName(input)).\(authority)" : authority
                var result = "\(scheme)://\(host)/"
                if let key = input.key {
                    result += key.urlEncodePath() ?? ""
                }
                return result
            }
        }
    }

    let actions = extraActions + [agenticAction]
    return Client(config) { opts in
        for action in actions {
            action(opts)
        }
    }
}
