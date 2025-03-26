import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = NSAttributedString(string: "")
    @State private var isBold = false
    @State private var isItalic = false
    var parentNote: Note?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("Title", text: $title)
                        .font(.headline)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    RichTextEditor(attributedText: $content, isBold: $isBold, isItalic: $isItalic)
                        .frame(height: 200)
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
            .navigationTitle(parentNote == nil ? "New Note" : "New Sub-Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !title.isEmpty {
                            viewModel.addNote(title: title, content: content.string, parentNote: parentNote)
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(title.isEmpty)
                }
            }
            .background(Color.white)
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(viewModel: NoteViewModel())
    }
}
