import Foundation
import SwiftUI

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var contentData: Data // Store the serialized NSAttributedString
    var children: [Note]?
    var parentID: UUID? // Store the parent's ID instead of a direct reference
    
    // Computed property to convert contentData to NSAttributedString
    var attributedContent: NSAttributedString {
        get {
            if let attributedString = try? NSAttributedString(
                data: contentData,
                options: [.documentType: NSAttributedString.DocumentType.rtfd],
                documentAttributes: nil
            ) {
                return attributedString
            }
            return NSAttributedString(string: "")
        }
        set {
            if let data = try? newValue.data(
                from: NSRange(location: 0, length: newValue.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
            ) {
                contentData = data
            } else {
                contentData = Data()
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, attributedContent: NSAttributedString, children: [Note]? = nil, parentID: UUID? = nil) {
        self.id = id
        self.title = title
        self.children = children
        self.parentID = parentID
        if let data = try? attributedContent.data(
            from: NSRange(location: 0, length: attributedContent.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
        ) {
            self.contentData = data
        } else {
            self.contentData = Data()
        }
    }
}
