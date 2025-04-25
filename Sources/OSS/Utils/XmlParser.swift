import Foundation
#if canImport(FoundationXML)
    import FoundationXML
#endif

protocol Parser {
    func parse(data: Data) -> [String: Any]
}

public class XmlParser: NSObject, Parser, XMLParserDelegate {
    var response: [String: Any] = [:]
    let elementStack = Stack<ElementNode>()
    var rootNode: ElementNode?

    public private(set) var lastError: Error?

    public func parse(data: Data) -> [String: Any] {
        let xml = XMLParser(data: data)
        xml.delegate = self
        let _ = xml.parse()
        return response
    }

    public func parserDidStartDocument(_: XMLParser) {}

    public func parserDidEndDocument(_: XMLParser) {
        if let e = rootNode?.asDictionary() {
            response = e
        }
    }

    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes _: [String: String] = [:]) {
        let elementNode = ElementNode(key: elementName)
        if let topNode = elementStack.top() {
            topNode.nodes.append(elementNode)
        } else {
            rootNode = elementNode
        }
        elementStack.push(element: elementNode)
    }

    public func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {
        elementStack.pop()
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        let value = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value != "" else {
            return
        }
        if let elementNode = elementStack.top() {
            if let v = elementNode.value {
                elementNode.value = v.appending(value)
            } else {
                elementNode.value = value
            }
        }
    }

    public func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        lastError = parseError
    }
}

class Stack<Element> {
    private var rootNode: Node?

    public func push(element: Element) {
        let node = Node(value: element)
        if let rootNode = rootNode {
            node.next = rootNode
        }
        rootNode = node
    }

    @discardableResult
    public func pop() -> Element? {
        let node = rootNode
        rootNode = node?.next
        return node?.value
    }

    public func top() -> Element? {
        return rootNode?.value
    }

    public func isEmpty() -> Bool {
        return rootNode == nil
    }

    class Node {
        let value: Element
        var next: Node?

        init(value: Element) {
            self.value = value
        }
    }
}

class ElementNode {
    private let key: String
    var value: String?
    var nodes: [ElementNode]

    init(key: String) {
        self.key = key
        nodes = []
    }

    public func asDictionary() -> [String: Any]? {
        if let e = getEntry() {
            return [e.0: e.1]
        }
        return nil
    }

    private func getEntry() -> (String, Any)? {
        if let value = value {
            return (key, value)
        }
        if nodes.count == 0 {
            return nil
        }
        let entry = nodes.reduce(into: [String: Any]()) {
            if let entry = $1.getEntry() {
                if let value = $0[entry.0] {
                    var array = value as? [Any] ?? [value]
                    array.append(entry.1)
                    $0[entry.0] = array
                } else {
                    $0[entry.0] = entry.1
                }
            }
        }
        return (key, entry)
    }
}

public extension Dictionary {
    static func withXMLData(data: Data) throws -> [String: Any] {
        let response = XmlParser()
        let result = response.parse(data: data)
        if let error = response.lastError {
            throw error
        }
        return result
    }

    static func withXMLDataError(data: Data) -> ([String: Any], Error?) {
        let response = XmlParser()
        let result = response.parse(data: data)
        return (result, response.lastError)
    }
}
