import Foundation
import SwiftUI

class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    init() {
        loadNotes()
    }
    
    func addNote(title: String, content: String, parentNote: Note? = nil) {
        let newNote = Note(title: title, content: content)
        if let parent = parentNote {
            if let index = notes.firstIndex(where: { $0.id == parent.id }) {
                notes[index].subNotes.append(newNote)
            }
        } else {
            notes.append(newNote)
        }
        saveNotes()
        print("Added note: \(newNote.title), Total notes: \(notes.count)")
    }
    
    func updateNote(_ note: Note, parentNote: Note? = nil) {
        if let parent = parentNote {
            if let parentIndex = notes.firstIndex(where: { $0.id == parent.id }),
               let subNoteIndex = notes[parentIndex].subNotes.firstIndex(where: { $0.id == note.id }) {
                notes[parentIndex].subNotes[subNoteIndex] = note
            }
        } else {
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        }
        saveNotes()
        print("Updated note: \(note.title)")
    }
    
    func deleteNote(at offsets: IndexSet, from parentNote: Note?) {
        if let parent = parentNote {
            if let index = notes.firstIndex(where: { $0.id == parent.id }) {
                notes[index].subNotes.remove(atOffsets: offsets)
            }
        } else {
            notes.remove(atOffsets: offsets)
        }
        saveNotes()
        print("Deleted notes at offsets: \(offsets), Total notes: \(notes.count)")
    }
    
    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: "notes")
            print("Saved notes successfully: \(notes.count) notes")
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: "notes") {
            print("Raw UserDefaults data: \(data)") // Debug log
            do {
                let savedNotes = try JSONDecoder().decode([Note].self, from: data)
                notes = savedNotes
                print("Loaded \(notes.count) notes successfully")
            } catch {
                print("Failed to load notes: \(error)")
                notes = []
            }
        } else {
            print("No saved notes found in UserDefaults")
            notes = []
        }
    }
    
    // Temporary method to reset UserDefaults
    func resetNotes() {
        UserDefaults.standard.removeObject(forKey: "notes")
        notes = []
        print("Reset UserDefaults, notes cleared")
    }
}
