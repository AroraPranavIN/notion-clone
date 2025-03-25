import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    
    init(id: UUID, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}
