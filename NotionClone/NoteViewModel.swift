import Foundation

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private let notesKey = "notesKey"
    
    init() {
        loadNotes()
    }
    
    func addNote(title: String, attributedContent: NSAttributedString, parentNote: Note?) {
        let newNote = Note(
            title: title,
            attributedContent: attributedContent,
            parentID: parentNote?.id
        )
        
        if let parent = parentNote {
            if let parentIndex = notes.firstIndex(where: { $0.id == parent.id }) {
                var updatedParent = notes[parentIndex]
                updatedParent.children = (updatedParent.children ?? []) + [newNote]
                notes[parentIndex] = updatedParent
            }
        } else {
            notes.append(newNote)
        }
        
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(at offsets: IndexSet, from parentNote: Note?) {
        if let parent = parentNote {
            if let parentIndex = notes.firstIndex(where: { $0.id == parent.id }) {
                var updatedParent = notes[parentIndex]
                updatedParent.children?.remove(atOffsets: offsets)
                notes[parentIndex] = updatedParent
            }
        } else {
            notes.remove(atOffsets: offsets)
        }
        
        saveNotes()
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let savedNotes = try? JSONDecoder().decode([Note].self, from: data) {
            self.notes = savedNotes
        } else {
            self.notes = []
        }
    }
    
    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: notesKey)
        }
    }
}
