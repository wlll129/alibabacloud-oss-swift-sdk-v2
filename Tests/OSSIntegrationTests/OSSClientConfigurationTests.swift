import AlibabaCloudOSS
import Foundation
import XCTest

class ClientConfigurationTests: BaseTestCase {
    override func setUp() async throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try await super.setUp()
    }

    func testMaxConcurrentRequestCount() throws {
//        let credentialsProvider = OSSAuthCredentialsProvider(authServerUrl: URL(string: stsUrl)!)
//        var config = ClientConfiguration(endpoint: endpoint,
//                                            credentialsProvider: credentialsProvider)
//        config.maxConnectionsPerHost = 5
//        let client = Client(config)
//
//        let group = DispatchGroup()
//        var flag: [Int: Bool] = [:]
//        for i in 0..<10 {
//            group.enter()
//            flag[i] = false
//            let request = PutObjectRequestOld(bucket: bucketName, objectKey: FileName.middle.rawValue, uploadable: .file(FileName.middle.fileUrl()))
//                .withProgress { bytesSent, totalBytesSent, totalBytesExpectedToSend in
//                    if flag[i] == false {
//                        objc_sync_enter(self)
//                        flag[i] = true
//                        objc_sync_exit(self)
//                    }
//                    var num = 0
//                    for (_, value) in flag {
//                        if value {
//                            num += 1
//                        }
//                    }
//                    print("num: \(num)")
//                    XCTAssertTrue(num <= config.maxConnectionsPerHost)
//                    print("bytesSent: \(bytesSent), totalBytesSent: \(totalBytesSent), totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
//                }
//            Task {
//                do {
//                    try await client.putObject(request: request)
//                    flag[i] = false
//                    group.leave()
//                } catch {
//
//                }
//            }
//        }
//        group.wait()
    }
}
