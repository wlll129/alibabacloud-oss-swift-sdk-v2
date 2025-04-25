import Foundation

public struct AttributeKey<ValueType>: Sendable {
    let name: Swift.String

    public init(name: Swift.String) {
        self.name = name
    }

    func toString() -> Swift.String {
        return "AttributeKey: \(name)"
    }
}

public struct Attributes: @unchecked Sendable {
    private var attributes = [Swift.String: Any]()
    public var size: Swift.Int { attributes.count }

    public init() {}

    public func get<T>(key: AttributeKey<T>) -> T? {
        guard let vals = values(key: key) else {
            return nil
        }
        return vals.first
    }

    public func values<T>(key: AttributeKey<T>) -> [T]? {
        attributes[key.name] as? [T]
    }

    public func contains<T>(key: AttributeKey<T>) -> Bool {
        get(key: key) != nil
    }

    public mutating func set<T>(key: AttributeKey<T>, value: T) {
        attributes[key.name] = [value]
    }

    public mutating func set<T>(key: AttributeKey<T>, value: [T]) {
        attributes[key.name] = value
    }

    public mutating func append<T>(key: AttributeKey<T>, value: T) {
        if var vals = values(key: key) {
            vals.append(value)
            attributes[key.name] = vals
        } else {
            attributes[key.name] = [value]
        }
    }

    public mutating func remove<T>(key: AttributeKey<T>) {
        attributes.removeValue(forKey: key.name)
    }
}

public enum AttributeKeys {
    public static let subResource = AttributeKey<Swift.String>(name: "sub-resource")
    public static let expirationTime = AttributeKey<Foundation.Date>(name: "expiration-time")
}
