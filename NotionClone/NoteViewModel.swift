import Foundation

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = [] {
        didSet {
            saveNotes()
        }
    }
    
    private let notesKey = "savedNotes"
    
    init() {
        loadNotes()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        print("Added note: \(note.title) with ID: \(note.id)")
    }
    
    func updateNote(_ updatedNote: Note) {
        if let index = notes.firstIndex(where: { $0.id == updatedNote.id }) {
            print("Updating note with ID: \(updatedNote.id), Title: \(updatedNote.title)")
            notes[index] = updatedNote
            print("Updated note at index \(index): \(notes[index].title)")
            // Force a UI refresh by reassigning the array
            notes = notes
        } else {
            print("Failed to update note: Note with ID \(updatedNote.id) not found")
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        print("Deleted note: \(note.title)")
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
            print("Saved \(notes.count) notes to UserDefaults")
        } else {
            print("Failed to save notes to UserDefaults")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            self.notes = decoded
            print("Loaded \(notes.count) notes from UserDefaults")
        } else {
            self.notes = []
            print("No notes found in UserDefaults")
        }
    }
}
