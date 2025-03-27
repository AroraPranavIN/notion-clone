import SwiftUI

struct NoteRow: View {
    let note: Note
    let viewModel: NoteViewModel
    @State private var showingAddSubNote = false
    
    var body: some View {
        VStack {
            NavigationLink {
                NoteDetailView(viewModel: viewModel, note: note)
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(note.attributedContent.string)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 4)
            }
            .onTapGesture {
                print("Tapped note in NoteRow: \(note.title), ID: \(note.id)")
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
                AddNoteView(viewModel: viewModel, parentID: note.id) // Use parentID
            }
            
            if let children = note.children, !children.isEmpty {
                List {
                    ForEach(children) { subNote in
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
                if notes.isEmpty {
                    Text("No notes available")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(notes) { note in
                        NavigationLink {
                            NoteDetailView(viewModel: viewModel, note: note)
                        } label: {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.blue)
                                Text(note.title)
                                    .foregroundColor(.primary)
                            }
                        }
                        .onTapGesture {
                            print("Tapped note in SidebarView: \(note.title), ID: \(note.id)")
                        }
                    }
                    .onDelete { offsets in
                        viewModel.deleteNote(at: offsets, from: nil)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddNote = true
                    print("Tapped + button in SidebarView, showingAddNote: \(showingAddNote)")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// Subview for the detail view (list of notes with sub-notes)
struct DetailView: View {
    let notes: [Note]
    let viewModel: NoteViewModel
    @Binding var showingAddNote: Bool // Add binding to show the sheet from DetailView
    
    var body: some View {
        List {
            if notes.isEmpty {
                Text("No notes available")
                    .foregroundColor(.secondary)
            } else {
                ForEach(notes) { note in
                    NoteRow(note: note, viewModel: viewModel)
                }
                .onDelete { offsets in
                    viewModel.deleteNote(at: offsets, from: nil)
                }
            }
        }
        .navigationTitle("NotionClone")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddNote = true
                    print("Tapped + button in DetailView, showingAddNote: \(showingAddNote)")
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
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
            DetailView(notes: viewModel.notes, viewModel: viewModel, showingAddNote: $showingAddNote)
        }
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(viewModel: viewModel) // No parentID for top-level notes
                .onDisappear {
                    print("AddNoteView dismissed, showingAddNote: \(showingAddNote)")
                }
        }
        .onAppear {
            print("ContentView appeared with \(viewModel.notes.count) notes")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
