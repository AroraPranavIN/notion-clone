import SwiftUI

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    let note: Note
    @State private var title: String
    @State private var attributedContent: NSAttributedString
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var textColor: UIColor? = nil
    @State private var backgroundColor: UIColor? = nil
    @State private var adjustFontSize: Int = 0
    @State private var showingTextColorPicker: Bool = false
    @State private var showingBackgroundColorPicker: Bool = false
    
    init(viewModel: NoteViewModel, note: Note) {
        self.viewModel = viewModel
        self.note = note
        self._title = State(initialValue: note.title)
        self._attributedContent = State(initialValue: note.attributedContent)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Title", text: $title)
                    .font(.title)
                    .padding()
                
                RichTextEditor(
                    attributedText: $attributedContent,
                    isBold: $isBold,
                    isItalic: $isItalic,
                    isUnderlined: $isUnderlined,
                    textColor: $textColor,
                    backgroundColor: $backgroundColor,
                    adjustFontSize: $adjustFontSize
                )
                .padding()
                
                // Formatting toolbar
                HStack(spacing: 15) {
                    // Bold
                    Button(action: {
                        isBold.toggle()
                    }) {
                        Image(systemName: isBold ? "bold.fill" : "bold")
                            .foregroundColor(isBold ? .blue : .gray)
                            .padding(8)
                            .background(isBold ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Italic
                    Button(action: {
                        isItalic.toggle()
                    }) {
                        Image(systemName: isItalic ? "italic.fill" : "italic")
                            .foregroundColor(isItalic ? .blue : .gray)
                            .padding(8)
                            .background(isItalic ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Underline
                    Button(action: {
                        isUnderlined.toggle()
                    }) {
                        Image(systemName: isUnderlined ? "underline.fill" : "underline")
                            .foregroundColor(isUnderlined ? .blue : .gray)
                            .padding(8)
                            .background(isUnderlined ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Text Color
                    Button(action: {
                        showingTextColorPicker = true
                    }) {
                        Image(systemName: "textformat")
                            .foregroundColor(textColor != nil ? Color(textColor!) : .gray)
                            .padding(8)
                            .background(textColor != nil ? Color(textColor!).opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showingTextColorPicker) {
                        VStack {
                            ColorPicker("Text Color", selection: Binding(
                                get: { Color(textColor ?? .black) },
                                set: { newColor in
                                    textColor = UIColor(newColor)
                                    print("Selected textColor: \(String(describing: textColor))")
                                }
                            ))
                            .padding()
                            
                            Button("Done") {
                                showingTextColorPicker = false
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Background Color
                    Button(action: {
                        showingBackgroundColorPicker = true
                    }) {
                        Image(systemName: "paintbrush")
                            .foregroundColor(backgroundColor != nil ? Color(backgroundColor!) : .gray)
                            .padding(8)
                            .background(backgroundColor != nil ? Color(backgroundColor!).opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showingBackgroundColorPicker) {
                        VStack {
                            ColorPicker("Background Color", selection: Binding(
                                get: { Color(backgroundColor ?? .clear) },
                                set: { newColor in
                                    backgroundColor = UIColor(newColor)
                                    print("Selected backgroundColor: \(String(describing: backgroundColor))")
                                }
                            ))
                            .padding()
                            
                            Button("Done") {
                                showingBackgroundColorPicker = false
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }
                    }
                    
                    // Font Size Adjustment
                    Button(action: {
                        adjustFontSize -= 1
                    }) {
                        Image(systemName: "textformat.size.smaller")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        adjustFontSize += 1
                    }) {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .navigationTitle("Edit Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedNote = Note(
                            id: note.id,
                            title: title.isEmpty ? "Untitled Note" : title,
                            attributedContent: attributedContent,
                            parentNote: note.parentNote
                        )
                        viewModel.updateNote(updatedNote)
                        dismiss()
                    }
                    .disabled(attributedContent.string.isEmpty)
                }
            }
        }
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var previews: some View {
        EditNoteView(viewModel: NoteViewModel(), note: Note(title: "Sample Note", attributedContent: NSAttributedString(string: "Sample content")))
    }
}
