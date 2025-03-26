import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var subNotes: [Note]
    
    init(id: UUID = UUID(), title: String, content: String, subNotes: [Note] = []) {
        self.id = id
        self.title = title
        self.content = content
        self.subNotes = subNotes
    }
}
