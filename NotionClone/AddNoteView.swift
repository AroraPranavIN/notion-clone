import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var content = ""
    
    var body: some View{
        NavigationView{
            Form {
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !title.isEmpty {
                            viewModel.addNote(title: title, content: content)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
