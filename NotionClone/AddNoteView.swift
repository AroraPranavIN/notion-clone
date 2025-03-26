import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "")
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var textColor: UIColor? = nil
    @State private var backgroundColor: UIColor? = nil
    @State private var adjustFontSize: Int = 0
    var parentNote: Note? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                }
                
                Section(header: Text("Content")) {
                    RichTextEditor(
                        attributedText: $attributedText,
                        isBold: $isBold,
                        isItalic: $isItalic,
                        isUnderlined: $isUnderlined,
                        textColor: $textColor,
                        backgroundColor: $backgroundColor,
                        adjustFontSize: $adjustFontSize
                    )
                    .frame(height: 200)
                }
                
                Section {
                    HStack {
                        Button(action: {
                            isBold.toggle()
                        }) {
                            Text("B")
                                .bold()
                                .frame(width: 30, height: 30)
                                .background(isBold ? Color.gray : Color.clear)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            isItalic.toggle()
                        }) {
                            Text("I")
                                .italic()
                                .frame(width: 30, height: 30)
                                .background(isItalic ? Color.gray : Color.clear)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            isUnderlined.toggle()
                        }) {
                            Text("U")
                                .underline()
                                .frame(width: 30, height: 30)
                                .background(isUnderlined ? Color.gray : Color.clear)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            adjustFontSize = 1
                        }) {
                            Text("A+")
                                .frame(width: 30, height: 30)
                                .background(Color.clear)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            adjustFontSize = -1
                        }) {
                            Text("A-")
                                .frame(width: 30, height: 30)
                                .background(Color.clear)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addNote(title: title.isEmpty ? "Untitled" : title, content: attributedText.string, parentNote: parentNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty && attributedText.string.isEmpty)
                }
            }
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        AddNoteView(viewModel: NoteViewModel())
    }
}
