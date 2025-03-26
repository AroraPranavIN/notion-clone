import SwiftUI

struct NoteDetailView: View {
    @State var note: Note
    @ObservedObject var viewModel: NoteViewModel
    @State private var editedTitle: String
    @State private var editedContent: NSAttributedString
    @State private var isBold = false
    @State private var isItalic = false
    var parentNote: Note?
    
    init(note: Note, viewModel: NoteViewModel, parentNote: Note? = nil) {
        self.note = note
        self.viewModel = viewModel
        self.parentNote = parentNote
        self._editedTitle = State(initialValue: note.title)
        self._editedContent = State(initialValue: NSAttributedString(string: note.content))
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle)
                    .font(.system(size: 18, weight: .medium)) // Explicitly set font size
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                RichTextEditor(attributedText: $editedContent, isBold: $isBold, isItalic: $isItalic)
                    .frame(height: 300)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
            }
            HStack {
                Button(action: { isBold.toggle() }) {
                    Image(systemName: isBold ? "bold.fill" : "bold")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Button(action: { isItalic.toggle() }) {
                    Image(systemName: isItalic ? "italic.fill" : "italic")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Edit Note")
        .background(Color.white)
        .onDisappear {
            if editedTitle != note.title || editedContent.string != note.content {
                let updatedNote = Note(id: note.id, title: editedTitle, content: editedContent.string, subNotes: note.subNotes)
                viewModel.updateNote(updatedNote, parentNote: parentNote)
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(note: Note(title: "Sample", content: "Content"), viewModel: NoteViewModel())
    }
}
