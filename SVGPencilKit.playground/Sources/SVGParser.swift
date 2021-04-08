import Foundation
import CoreGraphics

public struct SVG {
    public let paths: [String]
    public let kanji: String
    public let size: CGSize

    static let none = SVG(paths: [], kanji: "", size: .zero)
}

public class SVGParser: NSObject, XMLParserDelegate {

    private var about = [String: String]()
    private var kanji = ""
    private var paths = [String]()
    private var width = ""
    private var height = ""
    private var isKanjiSet = false

    public func parse(resource: String) -> SVG {
        let parser = XMLParser(contentsOf:  Bundle.main.url(forResource: resource, withExtension: "svg")!)

        parser?.delegate = self
        if parser!.parse() {
            let size = CGSize(
                width: Double(width) ?? .zero,
                height: Double(height) ?? .zero
            )
            let svg = SVG(
                paths: paths,
                kanji: kanji,
                size: size
            )
            return svg
        }
        return .none
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "svg":
            if let height = attributeDict["height"] {
                self.height = height
            }
            if let width = attributeDict["width"] {
                self.width = width
            }
        case "g":
            if let kanji = attributeDict["kvg:element"], !isKanjiSet {
                isKanjiSet = true
                self.kanji = kanji
            }
        case "path":
            if let d = attributeDict["d"] {
                paths.append(d)
            }
        default: break
        }
    }

    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
