import Foundation

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    init() {
        notes = [
            Note(id: UUID(), title: "Welcome to NotionClone", content: "This is your first note!"),
            Note(id: UUID(), title: "Swift Practice", content: "Learning SwiftUI is fun!")
        ]
    }
    
    func addNote(title: String, content: String) {
        let newNote = Note(id: UUID(), title: title, content: content)
        notes.append(newNote)
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: {$0.id == note.id }) {
            notes[index] = note
        }
    }
}
