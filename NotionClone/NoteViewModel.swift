import Foundation

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("notes.json")
        
        loadNotes()
        
        if notes.isEmpty {
            notes = [
                Note(id: UUID(), title: "Welcome to NotionClone", content: "This is your first note!", subNotes: [
                    Note(id: UUID(), title: "Sub-Note 1", content: "This is a sub-note.", subNotes: [])
                ]),
                Note(id: UUID(), title: "Swift Practice", content: "Learning SwiftUI is fun!", subNotes: [])
            ]
            saveNotes()
        }
    }
    
    func addNote(title: String, content: String, parentNote: Note? = nil) {
        let newNote = Note(title: title, content: content)
        if let parent = parentNote, let parentIndex = notes.firstIndex(where: { $0.id == parent.id }) {
            notes[parentIndex].subNotes.append(newNote)
        } else {
            notes.append(newNote)
        }
        saveNotes()
    }
    
    func updateNote(_ note: Note, parentNote: Note? = nil) {
        if let parent = parentNote, let parentIndex = notes.firstIndex(where: { $0.id == parent.id }) {
            if let subIndex = notes[parentIndex].subNotes.firstIndex(where: { $0.id == note.id }) {
                notes[parentIndex].subNotes[subIndex] = note
            }
        } else if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        }
        saveNotes()
    }
    
    func deleteNote(at offsets: IndexSet, from parentNote: Note? = nil) {
        if let parent = parentNote, let parentIndex = notes.firstIndex(where: { $0.id == parent.id }) {
            notes[parentIndex].subNotes.remove(atOffsets: offsets)
        } else {
            notes.remove(atOffsets: offsets)
        }
        saveNotes()
    }
    
    private func saveNotes() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(notes)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            notes = try decoder.decode([Note].self, from: data)
        } catch {
            print("Failed to load notes: \(error)")
            notes = []
        }
    }
}
