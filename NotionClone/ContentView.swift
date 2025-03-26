import SwiftUI

struct NoteRow: View {
    let note: Note
    let viewModel: NoteViewModel
    @State private var showingAddSubNote = false
    
    var body: some View {
        VStack {
            NavigationLink {
                NoteDetailView(note: note, viewModel: viewModel, parentNote: nil)
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(note.content)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 4)
            }
            .contextMenu {
                Button(action: {
                    showingAddSubNote = true
                }) {
                    Text("Add Sub-Note")
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddSubNote) {
                AddNoteView(viewModel: viewModel, parentNote: note)
            }
            
            if !note.subNotes.isEmpty {
                List {
                    ForEach(note.subNotes) { subNote in
                        NoteRow(note: subNote, viewModel: viewModel)
                    }
                    .onDelete { offsets in
                        viewModel.deleteNote(at: offsets, from: note)
                    }
                }
                .padding(.leading, 20)
                .background(Color.gray.opacity(0.1))
            }
        }
    }
}

// Subview for the sidebar
struct SidebarView: View {
    let notes: [Note]
    let viewModel: NoteViewModel
    @Binding var showingAddNote: Bool
    
    var body: some View {
        List {
            Section(header: Text("Notes").font(.title2).foregroundColor(.blue)) {
                ForEach(notes) { note in
                    NavigationLink {
                        NoteDetailView(note: note, viewModel: viewModel, parentNote: nil)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text(note.title)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteNote(at: offsets, from: nil)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .background(Color.gray.opacity(0.05))
    }
}

// Subview for the detail view (list of notes with sub-notes)
struct DetailView: View {
    let notes: [Note]
    let viewModel: NoteViewModel
    
    var body: some View {
        List {
            ForEach(notes) { note in
                NoteRow(note: note, viewModel: viewModel)
            }
            .onDelete { offsets in
                viewModel.deleteNote(at: offsets, from: nil)
            }
        }
        .navigationTitle("NotionClone")
        .background(Color.white)
    }
}

// Main ContentView
struct ContentView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(notes: viewModel.notes, viewModel: viewModel, showingAddNote: $showingAddNote)
        } detail: {
            DetailView(notes: viewModel.notes, viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
