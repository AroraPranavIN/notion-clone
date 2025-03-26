import SwiftUI

struct NoteDetailView: View {
    @State var note: Note
    @ObservedObject var viewModel: NoteViewModel
    @State private var editedTitle: String
    @State private var editedContent: NSAttributedString
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderlined = false
    @State private var textColor: UIColor?
    @State private var backgroundColor: UIColor?
    @State private var adjustFontSize: Int = 0
    @State private var showingTextColorPicker = false
    @State private var showingBackgroundColorPicker = false
    @State private var forceUpdate: Bool = false
    
    var parentNote: Note?
    
    init(note: Note, viewModel: NoteViewModel, parentNote: Note? = nil) {
        self.note = note
        self.viewModel = viewModel
        self.parentNote = parentNote
        self._editedTitle = State(initialValue: note.title)
        let defaultFont = UIFont(name: "Helvetica", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key: Any] = [.font: defaultFont]
        self._editedContent = State(initialValue: NSAttributedString(string: note.content, attributes: attributes))
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle)
                    .font(.system(size: 18, weight: .medium))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                RichTextEditor(
                    attributedText: $editedContent,
                    isBold: $isBold,
                    isItalic: $isItalic,
                    isUnderlined: $isUnderlined,
                    textColor: $textColor,
                    backgroundColor: $backgroundColor,
                    adjustFontSize: $adjustFontSize
                )
                .id(forceUpdate)
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
                Button(action: { isUnderlined.toggle() }) {
                    Image(systemName: isUnderlined ? "underline.fill" : "underline")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Button(action: { showingTextColorPicker.toggle() }) {
                    Image(systemName: "textformat")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showingTextColorPicker) {
                    VStack {
                        Text("Select Text Color")
                            .font(.headline)
                            .padding()
                        Button(action: {
                            textColor = .red
                        }) {
                            Text("Red")
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                        Button(action: {
                            textColor = .blue
                        }) {
                            Text("Blue")
                                .foregroundColor(.blue)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                        Button(action: {
                            textColor = nil
                        }) {
                            Text("Default")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                        Button("Done") {
                            showingTextColorPicker = false
                            forceUpdate.toggle()
                        }
                        .padding()
                    }
                    .padding()
                }
                Button(action: { showingBackgroundColorPicker.toggle() }) {
                    Image(systemName: "highlighter")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showingBackgroundColorPicker) {
                    VStack {
                        Text("Select Highlight Color")
                            .font(.headline)
                            .padding()
                        Button(action: {
                            backgroundColor = .yellow
                        }) {
                            Text("Yellow")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow.opacity(0.5))
                        }
                        Button(action: {
                            backgroundColor = .green
                        }) {
                            Text("Green")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.5))
                        }
                        Button(action: {
                            backgroundColor = nil
                        }) {
                            Text("None")
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                        }
                        Button("Done") {
                            showingBackgroundColorPicker = false
                            forceUpdate.toggle()
                        }
                        .padding()
                    }
                    .padding()
                }
                Button(action: { adjustFontSize = -1 }) {
                    Image(systemName: "textformat.size.smaller")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Button(action: { adjustFontSize = 1 }) {
                    Image(systemName: "textformat.size.larger")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground)) // Dynamic background for the toolbar
        }
        .navigationTitle("Edit Note")
        // Removed .background(Color.white) to allow system background
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
