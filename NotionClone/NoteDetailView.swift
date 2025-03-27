import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteViewModel
    let note: Note
    
    var body: some View {
        VStack {
            Text(note.title)
                .font(.title)
            
            // Display the attributed content
            AttributedTextView(attributedText: note.attributedContent)
                .frame(maxHeight: .infinity)
            
            // Add a button to edit the note
            NavigationLink(destination: EditNoteView(viewModel: viewModel, note: note)) {
                Text("Edit Note")
            }
        }
        .padding()
        .navigationTitle(note.title)
    }
}

// A simple view to display NSAttributedString
struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.attributedText = attributedText
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(viewModel: NoteViewModel(), note: Note(title: "Sample Note", attributedContent: NSAttributedString(string: "Sample content")))
    }
}
