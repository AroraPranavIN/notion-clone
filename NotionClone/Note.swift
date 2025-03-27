import Foundation
import UIKit // Add this import for UIColor

class Note: NSObject, Identifiable, Codable {
    let id: UUID
    let title: String
    let attributedContent: NSAttributedString
    let parentNote: Note?
    
    init(id: UUID = UUID(), title: String, attributedContent: NSAttributedString, parentNote: Note? = nil) {
        self.id = id
        self.title = title
        self.attributedContent = attributedContent
        self.parentNote = parentNote
        super.init()
    }
    
    // Custom Codable implementation to handle NSAttributedString
    enum CodingKeys: String, CodingKey {
        case id, title, contentData, parentNote
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let data = try container.decode(Data.self, forKey: .contentData)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil) {
            attributedContent = attributedString
            print("Deserialized NSAttributedString has background color: \(attributedString.hasBackgroundColor())")
        } else {
            attributedContent = NSAttributedString(string: "")
        }
        parentNote = try container.decodeIfPresent(Note.self, forKey: .parentNote)
        super.init()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        if let data = try? attributedContent.data(from: NSRange(location: 0, length: attributedContent.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]) {
            try container.encode(data, forKey: .contentData)
            print("Serialized NSAttributedString with background color: \(attributedContent.hasBackgroundColor())")
        } else {
            try container.encode(Data(), forKey: .contentData)
        }
        try container.encodeIfPresent(parentNote, forKey: .parentNote)
    }
}

extension NSAttributedString {
    func hasBackgroundColor() -> String {
        var result = "No background color"
        enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: length), options: []) { (value, range, stop) in
            if let color = value as? UIColor {
                result = "\(color) in range \(range)"
                stop.pointee = true
            }
        }
        return result
    }
}
