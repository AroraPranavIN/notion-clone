import SwiftUI

struct NoteDetailView: View {
    @State var note: Note
    @ObservedObject var viewModel: NoteViewModel
    @State private var edittedTitle: String
    @State private var edittedContent: String
    
    init(note: Note, viewModel: NoteViewModel) {
        self.note = note
        self.viewModel = viewModel
        self._edittedTitle = State(initialValue: note.title)
        self._edittedContent = State(initialValue: note.content)
    }
    
    var body: some View {
        Form {
            TextField("Title", text: $edittedTitle)
            TextField("Content", text: $edittedContent)
                .frame(height: 300)
        }
        .navigationTitle("Edit Note")
        .onDisappear {
            if edittedTitle != note.title || edittedContent != note.content {
                let updatedNote = Note(id: note.id, title: edittedTitle, content: edittedContent)
                viewModel.updateNote(updatedNote)
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(note: .init(id: UUID(), title: "Test", content: "Test"), viewModel: NoteViewModel())
    }
}
