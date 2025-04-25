import ArgumentParser
import Foundation
import AlibabaCloudOSS

struct Program: ParsableCommand {
    @Option(help: "The region in which the bucket is located.")
    var region: String?

    @Option(help: "The domain names that other services can use to access OSS.")
    var endpoint: String?

    @Option(help: "The name of the bucket.")
    var bucket: String?

    //@Option(help: "The name of the object.")
    //var key: String?
}

@main
struct Main {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())

        do {
            let opts = try Program.parse(args)
            if opts.region == nil {
                print("Please specify the region.")
                return
            }
            if opts.bucket == nil {
                print("Please specify the bucket.")
                return
            }

            // Using the SDK's default configuration
            // loading credentials values from the environment variables
            let credentialsProvider = EnvironmentCredentialsProvider()

            let config = Configuration.default()
                .withRegion(opts.region!)
                .withCredentialsProvider(credentialsProvider)

            if opts.endpoint != nil {
                config.withEndpoint(opts.endpoint!) 
            }

            let client = Client(config)

            let result = try await client.getBucketAcl(GetBucketAclRequest(bucket: opts.bucket!))

            print("get bucket acl done\n:\(result)")

        } catch {
            Program.exit(withError: error)
        }
    }
}
