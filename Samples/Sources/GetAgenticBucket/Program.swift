import AlibabaCloudOSS
import AlibabaCloudOSSAgentic
import ArgumentParser
import Foundation

struct Program: ParsableCommand {
    @Option(help: "The region in which the bucket is located.")
    var region: String

    @Option(help: "The domain names that other services can use to access OSS.")
    var endpoint: String?

    @Option(help: "The Alibaba Cloud account ID (UID).")
    var accountId: String

    @Option(help: "The user-defined prefix of the AgenticBucket name.")
    var bucket: String
    
    @Option(help: "Set if the endpoint is a short-alias host, set this flag to true.")
    var useVirtualHostedAlias: Bool?
}

@main
struct Main {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())

        do {
            let opts = try Program.parse(args)

            let region = opts.region
            let bucket = opts.bucket
            let endpoint = opts.endpoint
            let accountId = opts.accountId
            let useVirtualHostedAlias = opts.useVirtualHostedAlias

            // Using the SDK's default configuration
            // loading credentials values from the environment variables
            let credentialsProvider = EnvironmentCredentialsProvider()

            let config = Configuration.default()
                .withRegion(region)
                .withCredentialsProvider(credentialsProvider)
                .withAccountId(accountId)
                .withLogger(LogAgentNSLog(level: .debug))
            if let useVirtualHostedAlias {
                config.withUseVirtualHostedAlias(useVirtualHostedAlias)
            }
            if let endpoint = endpoint {
                config.withEndpoint(endpoint)
            }

            let client = AgenticBucketClient(config)

            let result = try await client.getAgenticBucket(
                GetAgenticBucketRequest(
                    bucket: bucket
                )
            )

            if let info = result.agenticBucketInfo {
                print("Name: \(info.name ?? "")")
                print("Region: \(info.region ?? "")")
                print("StorageClass: \(info.storageClass ?? "")")
                print("DataRedundancyType: \(info.dataRedundancyType ?? "")")
                print("Status: \(info.status ?? "")")
                print("CreateTime: \(info.createTime ?? "")")
            }

        } catch {
            Program.exit(withError: error)
        }
    }
}
