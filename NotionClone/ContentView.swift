import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationStack { // Changed from NavigationView to NavigationStack
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(viewModel: viewModel, note: note)) {
                        NoteRow(note: note)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.deleteNote(viewModel.notes[index])
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
            .onAppear {
                print("ContentView appeared with \(viewModel.notes.count) notes")
            }
        }
    }
}

struct NoteRow: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.title)
                .font(.headline)
            Text(note.attributedContent.string)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
