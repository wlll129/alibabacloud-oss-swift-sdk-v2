@testable import AlibabaCloudOSS
import XCTest

final class RefreshCredentialsProviderTests: XCTestCase {
    let validToken = Credentials(accessKeyId: "validTokenAccessKey",
                                 accessKeySecret: "validTokenSecretKey",
                                 securityToken: "validTokenToken",
                                 expiration: Date().addingTimeInterval(60 * 60))
    let invalidToken = Credentials(accessKeyId: "invalidTokenAccessKey",
                                   accessKeySecret: "invalidTokenSecretKey",
                                   securityToken: "invalidTokenToken",
                                   expiration: Date())

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClosureWithoutExpiration() async throws {
        let credentialsProvider = RefreshCredentialsProvider {
            Credentials(accessKeyId: "ak", accessKeySecret: "sk")
        }
        let token = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak", token.accessKeyId)
        XCTAssertEqual("sk", token.accessKeySecret)
        XCTAssertNil(token.securityToken)
        XCTAssertNil(token.expiration)
        XCTAssertFalse(token.isExpired)
    }

    func testClosureWithExpiration() async throws {
        var credentialsProvider = RefreshCredentialsProvider {
            Credentials(
                accessKeyId: "ak",
                accessKeySecret: "sk",
                securityToken: "token",
                expiration: Date().addingTimeInterval(10 * 60)
            )
        }
        var token = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak", token.accessKeyId)
        XCTAssertEqual("sk", token.accessKeySecret)
        XCTAssertEqual("token", token.securityToken)
        XCTAssertNotNil(token.expiration)
        XCTAssertFalse(token.isExpired)

        credentialsProvider = RefreshCredentialsProvider {
            Credentials(
                accessKeyId: "ak-1",
                accessKeySecret: "sk-1",
                securityToken: "token-1",
                expiration: Date().addingTimeInterval(1)
            )
        }
        token = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak-1", token.accessKeyId)
        XCTAssertEqual("sk-1", token.accessKeySecret)
        XCTAssertEqual("token-1", token.securityToken)
        XCTAssertNotNil(token.expiration)
        XCTAssertFalse(token.isExpired)
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            try await Task.sleep(for: .seconds(3))
        } else {
            try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
        }
        XCTAssertTrue(token.isExpired)
    }

    func testProviderWithoutExpiration() async throws {
        let credentialsProvider = RefreshCredentialsProvider(
            provider: StaticCredentialsProvider(accessKeyId: "ak", accessKeySecret: "sk")
        )
        let token = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak", token.accessKeyId)
        XCTAssertEqual("sk", token.accessKeySecret)
        XCTAssertNil(token.securityToken)
        XCTAssertNil(token.expiration)
        XCTAssertFalse(token.isExpired)
    }

    func testExpirationGraterThanRefreshInterval() async throws {
        let counter = Counter()
        let expiration = Date().addingTimeInterval(60 * 60)
        let credentialsProvider = RefreshCredentialsProvider {
            let cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration)
            await counter.increment()
            return cred
        }

        var testcnt = 0
        for _ in 0 ..< 30 {
            let token = try await credentialsProvider.getCredentials()
            XCTAssertEqual("ak-0", token.accessKeyId)
            XCTAssertEqual("sk-0", token.accessKeySecret)
            XCTAssertEqual("token-0", token.securityToken)
            XCTAssertEqual(expiration, token.expiration)
            testcnt += 1
        }
        XCTAssertEqual(30, testcnt)
        let count = await counter.getCount()
        XCTAssertEqual(1, count)
    }

    func testExpirationLessThanRefreshInterval() async throws {
        // default refreshInterval is 5 * 60
        let counter = Counter()
        let expiration = Date().addingTimeInterval(4 * 60)
        let credentialsProvider = RefreshCredentialsProvider {
            let cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration)
            await counter.increment()
            return cred
        }

        var cred = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak-0", cred.accessKeyId)
        XCTAssertEqual("sk-0", cred.accessKeySecret)
        XCTAssertEqual("token-0", cred.securityToken)
        XCTAssertEqual(expiration, cred.expiration)

        var testcnt = 0
        for _ in 0 ..< 30 {
            cred = try await credentialsProvider.getCredentials()
            XCTAssertEqual("ak-\(testcnt)", cred.accessKeyId)
            XCTAssertEqual("sk-\(testcnt)", cred.accessKeySecret)
            XCTAssertEqual("token-\(testcnt)", cred.securityToken)
            XCTAssertEqual(expiration, cred.expiration)
            testcnt += 1
            try await Task.sleep(nanoseconds: 1 * 200_000_000) // sleep 0.2 second
        }
        XCTAssertEqual(30, testcnt)
        let count = await counter.getCount()
        XCTAssertEqual(31, count)

        // don't not sleep
//        await counter.setCount(count: 0)
//        testcnt = 0
//        credentialsProvider = RefreshCredentialsProvider {
//            let cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
//                                         accessKeySecret: "sk-\(counter.getCount())",
//                                         securityToken: "token-\(counter.getCount())",
//                                         expiration: expiration)
//            await counter.increment()
//            return cred
//        }
//        cred = try await credentialsProvider.getCredentials()
//        XCTAssertEqual("ak-0", cred.accessKeyId)
//        XCTAssertEqual("sk-0", cred.accessKeySecret)
//        XCTAssertEqual("token-0", cred.securityToken)
//        XCTAssertEqual(expiration, cred.expiration)
//
//        for _ in 0..<30 {
//            cred = try await credentialsProvider.getCredentials()
//            XCTAssertEqual(expiration, cred.expiration)
//            testcnt += 1
//        }
//        XCTAssertEqual(30, testcnt)
//        XCTAssertTrue(count < 30)
    }

    func testUpdateDefaultRefreshInterval() async throws {
        // default refreshInterval is 5 * 60
        let counter = Counter()
        let expiration0 = Date().addingTimeInterval(4 * 60)
        let expiration1 = Date().addingTimeInterval(60 * 60)
        let credentialsProvider = RefreshCredentialsProvider {
            var cred: Credentials
            if await counter.getCount() == 0 {
                cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration0)
            } else {
                cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration1)
            }
            await counter.increment()
            return cred
        }

        // 1st
        var cred = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak-0", cred.accessKeyId)
        XCTAssertEqual("sk-0", cred.accessKeySecret)
        XCTAssertEqual("token-0", cred.securityToken)
        XCTAssertEqual(expiration0, cred.expiration)

        // 2st in cache
        cred = try await credentialsProvider.getCredentials()
        XCTAssertEqual("ak-0", cred.accessKeyId)
        XCTAssertEqual("sk-0", cred.accessKeySecret)
        XCTAssertEqual("token-0", cred.securityToken)
        XCTAssertEqual(expiration0, cred.expiration)

        // wait task done
        try await Task.sleep(nanoseconds: 1 * 200_000_000) // sleep 0.2 second

        var testcnt = 0
        for _ in 0 ..< 30 {
            cred = try await credentialsProvider.getCredentials()
            XCTAssertEqual("ak-1", cred.accessKeyId)
            XCTAssertEqual("sk-1", cred.accessKeySecret)
            XCTAssertEqual("token-1", cred.securityToken)
            XCTAssertEqual(expiration1, cred.expiration)
            testcnt += 1
        }
        XCTAssertEqual(30, testcnt)
        let count = await counter.getCount()
        XCTAssertEqual(2, count)
    }

    func testConcurrencyGetCredentials() async throws {
        // default refreshInterval is 5 * 60
        let counter = Counter()
        let expiration0 = Date().addingTimeInterval(5 * 60 + 15)
        let expiration1 = Date().addingTimeInterval(60 * 60)
        let credentialsProvider = RefreshCredentialsProvider {
            var cred: Credentials
            if await counter.getCount() == 0 {
                cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration0)
            } else {
                cred = await Credentials(accessKeyId: "ak-\(counter.getCount())",
                                         accessKeySecret: "sk-\(counter.getCount())",
                                         securityToken: "token-\(counter.getCount())",
                                         expiration: expiration1)
            }
            await counter.increment()
            return cred
        }

        // run task

        // run 12s
        var task0 = Task {
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 12 {
                let cred = try await credentialsProvider.getCredentials()
                XCTAssertEqual("ak-0", cred.accessKeyId)
                XCTAssertEqual("sk-0", cred.accessKeySecret)
                XCTAssertEqual("token-0", cred.securityToken)
                XCTAssertEqual(expiration0, cred.expiration)
            }
        }
        var task1 = Task {
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 12 {
                let cred = try await credentialsProvider.getCredentials()
                XCTAssertEqual("ak-0", cred.accessKeyId)
                XCTAssertEqual("sk-0", cred.accessKeySecret)
                XCTAssertEqual("token-0", cred.securityToken)
                XCTAssertEqual(expiration0, cred.expiration)
            }
        }
        try await task0.value
        try await task1.value

        // wait 5s
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000) // sleep 5 second

        // run 10s
        let _ = try await credentialsProvider.getCredentials()
        try await Task.sleep(nanoseconds: 1 * 200_000_000) // sleep 0.2 second

        task0 = Task {
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 12 {
                let cred = try await credentialsProvider.getCredentials()
                XCTAssertEqual("ak-1", cred.accessKeyId)
                XCTAssertEqual("sk-1", cred.accessKeySecret)
                XCTAssertEqual("token-1", cred.securityToken)
                XCTAssertEqual(expiration1, cred.expiration)
            }
        }
        task1 = Task {
            let startTime = Date()
            while Date().timeIntervalSince(startTime) < 12 {
                let cred = try await credentialsProvider.getCredentials()
                XCTAssertEqual("ak-1", cred.accessKeyId)
                XCTAssertEqual("sk-1", cred.accessKeySecret)
                XCTAssertEqual("token-1", cred.securityToken)
                XCTAssertEqual(expiration1, cred.expiration)
            }
        }
        try await task0.value
        try await task1.value
    }

    actor Counter {
        private var count = 0

        func setCount(count: Int) {
            self.count = count
        }

        func increment() {
            count += 1
        }

        func getCount() -> Int {
            return count
        }
    }
}
