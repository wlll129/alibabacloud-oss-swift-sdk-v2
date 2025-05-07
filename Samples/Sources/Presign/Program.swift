import AlibabaCloudOSS
import ArgumentParser
import Foundation

struct Program: ParsableCommand {
    @Option(help: "The region in which the bucket is located.")
    var region: String

    @Option(help: "The domain names that other services can use to access OSS.")
    var endpoint: String?
    
    @Option(help: "The api name for generates the pre-signed URL.")
    var api: String
    
    @Option(help: "The name of the bucket.")
    var bucket: String

    @Option(help: "The name of the object.")
    var key: String
    
    @Option(help: "The upload id of the object.")
    var uploadId: String?
}
@main
struct Main {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())

        do {
            let opts = try Program.parse(args)

            // Specify the region and other parameters.
            let region = opts.region
            let endpoint = opts.endpoint
            let bucket = opts.bucket
            let key = opts.key
            let api = opts.api
            let uploadId = opts.uploadId

            // Using the SDK's default configuration
            // loading credentials values from the environment variables
            let credentialsProvider = EnvironmentCredentialsProvider()

            let config = Configuration.default()
                .withRegion(region)
                .withCredentialsProvider(credentialsProvider)

            if let endpoint = endpoint {
                config.withEndpoint(endpoint)
            }

            let client = Client(config)

            switch api.lowercased() {
            case "putObject".lowercased():
                try await presignPutObject(client: client, bucket: bucket, key: key)
            case "getObject".lowercased():
                try await presignGetObject(client: client, bucket: bucket, key: key)
            case "headObject".lowercased():
                try await presignHeadObject(client: client, bucket: bucket, key: key)
            case "InitiateMultipartUpload".lowercased():
                try await presignInitiateMultipartUpload(client: client, bucket: bucket, key: key)
            case "UploadPart".lowercased():
                try await presignUploadPart(client: client, bucket: bucket, key: key, uploadId: uploadId)
            case "CompleteMultipartUpload".lowercased():
                try await presignCompleteMultipartUpload(client: client, bucket: bucket, key: key, uploadId: uploadId)
            case "AbortMultipartUpload".lowercased():
                try await presignAbortMultipartUpload(client: client, bucket: bucket, key: key, uploadId: uploadId)
            default:
                break
            }
        } catch {
            Program.exit(withError: error)
        }
    }
    
    static func presignGetObject(client: Client, bucket: String, key: String) async throws {
        
        let result = try await client.presign(
            GetObjectRequest(
                bucket: bucket,
                key: key
            )
        )
        print("presign result: \n\(result)")
        
        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
    
    static func presignPutObject(client: Client, bucket: String, key: String) async throws {
        let content = "hello oss".data(using: .utf8)!
        
        let result = try await client.presign(
            PutObjectRequest(
                bucket: bucket,
                key: key,
                body: .data(content)
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
    
    static func presignHeadObject(client: Client, bucket: String, key: String) async throws {
        
        let result = try await client.presign(
            HeadObjectRequest(
                bucket: bucket,
                key: key
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
    
    static func presignInitiateMultipartUpload(client: Client, bucket: String, key: String) async throws {
        
        let result = try await client.presign(
            InitiateMultipartUploadRequest(
                bucket: bucket,
                key: key
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)\ndata: \(String(bytes: data, encoding: .utf8)!)")
    }
    
    static func presignUploadPart(client: Client, bucket: String, key: String, uploadId: String?) async throws {
        let content = "hello oss".data(using: .utf8)!

        let result = try await client.presign(
            UploadPartRequest(
                bucket: bucket,
                key: key,
                partNumber: 1,
                uploadId: uploadId,
                body: .data(content)
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
    
    static func presignCompleteMultipartUpload(client: Client, bucket: String, key: String, uploadId: String?) async throws {
        
        let result = try await client.presign(
            CompleteMultipartUploadRequest(
                bucket: bucket,
                key: key,
                completeAll: "yes",
                uploadId: uploadId
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
    
    static func presignAbortMultipartUpload(client: Client, bucket: String, key: String, uploadId: String?) async throws {
        
        let result = try await client.presign(
            AbortMultipartUploadRequest(
                bucket: bucket,
                key: key,
                uploadId: uploadId
            )
        )
        print("presign result: \n\(result)")

        var urlRequest = URLRequest(url: URL(string: result.url)!)
        urlRequest.httpMethod = result.method
        for (key, value) in result.signedHeaders ?? [:] {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        
        print("response: \(response)")
    }
}

extension PresignResult: @retroactive CustomStringConvertible {
    public var description: String {
        """
        url: \(url)\n\
        method: \(method)\n\
        header: \((signedHeaders ?? [:]).map {
            "\($0.key): \($0.value)"
        }.joined(separator: "\n\t\t"))
        """
    }
}
