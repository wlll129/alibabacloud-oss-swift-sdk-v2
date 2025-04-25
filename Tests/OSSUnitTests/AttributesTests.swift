import AlibabaCloudOSS
import XCTest

class AttributesTests: XCTestCase {
    let strKey = AttributeKey<String>(name: "key-string")

    func testSetAndGetValue() {
        var subject = Attributes()

        subject.set(key: strKey, value: "123")

        XCTAssertEqual("123", subject.get(key: strKey))
    }

    func testSetAndGetArrayValue() {
        var subject = Attributes()

        subject.set(key: strKey, value: ["123", "456"])
        XCTAssertEqual("123", subject.get(key: strKey))

        let vals = subject.values(key: strKey)
        XCTAssertNotNil(vals)
        XCTAssertEqual(2, vals?.count)
        XCTAssertEqual("123", vals?[0])
        XCTAssertEqual("456", vals?[1])
    }

    func testSetAndGetValues() {
        var subject = Attributes()
        subject.set(key: strKey, value: "123")
        var vals = subject.values(key: strKey)
        XCTAssertNotNil(vals)
        XCTAssertEqual(1, vals?.count)
        XCTAssertEqual("123", vals?[0])

        subject = Attributes()
        subject.append(key: strKey, value: "1234")
        vals = subject.values(key: strKey)
        XCTAssertNotNil(vals)
        XCTAssertEqual(1, vals?.count)
        XCTAssertEqual("1234", vals?[0])

        subject = Attributes()
        subject.set(key: strKey, value: "123")
        subject.append(key: strKey, value: "456")
        vals = subject.values(key: strKey)
        XCTAssertNotNil(vals)
        XCTAssertEqual(2, vals?.count)
        XCTAssertEqual("123", vals?[0])
        XCTAssertEqual("456", vals?[1])
    }

    func testContains() {
        var subject = Attributes()
        XCTAssertFalse(subject.contains(key: strKey))

        subject.set(key: strKey, value: "123")
        XCTAssertTrue(subject.contains(key: strKey))
    }

    func testRemove() {
        var subject = Attributes()
        subject.set(key: strKey, value: "123")

        subject.remove(key: strKey)
        XCTAssertNil(subject.get(key: strKey))
    }
}
