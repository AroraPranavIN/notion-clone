import SwiftUI

struct EditNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    let note: Note
    @State private var title: String
    @State private var attributedText: NSAttributedString
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
        self._attributedText = State(initialValue: note.attributedContent)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                        .font(.system(size: 28, weight: .bold)) // Increase to 28 points and make bold
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
                
                Section(header: Text("Formatting")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // Bold Button
                            Button(action: {
                                isBold.toggle()
                            }) {
                                Text("B")
                                    .bold()
                                    .frame(width: 30, height: 30)
                                    .background(isBold ? Color.gray : Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            
                            // Italic Button
                            Button(action: {
                                isItalic.toggle()
                            }) {
                                Text("I")
                                    .italic()
                                    .frame(width: 30, height: 30)
                                    .background(isItalic ? Color.gray : Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            
                            // Underline Button
                            Button(action: {
                                isUnderlined.toggle()
                            }) {
                                Text("U")
                                    .underline()
                                    .frame(width: 30, height: 30)
                                    .background(isUnderlined ? Color.gray : Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            
                            // Font Size Increase Button
                            Button(action: {
                                adjustFontSize = 1
                            }) {
                                Text("A+")
                                    .frame(width: 30, height: 30)
                                    .background(Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            
                            // Font Size Decrease Button
                            Button(action: {
                                adjustFontSize = -1
                            }) {
                                Text("A-")
                                    .frame(width: 30, height: 30)
                                    .background(Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            
                            // Text Color Picker Button
                            Button(action: {
                                showingTextColorPicker = true
                            }) {
                                Image(systemName: "textformat")
                                    .frame(width: 30, height: 30)
                                    .background(textColor != nil ? Color(uiColor: textColor!) : Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            .sheet(isPresented: $showingTextColorPicker) {
                                ColorPickerView(selectedColor: $textColor)
                            }
                            
                            // Background Color Picker Button
                            Button(action: {
                                showingBackgroundColorPicker = true
                            }) {
                                Image(systemName: "paintbrush")
                                    .frame(width: 30, height: 30)
                                    .background(backgroundColor != nil ? Color(uiColor: backgroundColor!) : Color.clear)
                                    .foregroundColor(.primary)
                                    .clipShape(Circle())
                            }
                            .sheet(isPresented: $showingBackgroundColorPicker) {
                                ColorPickerView(selectedColor: $backgroundColor)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
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
                        // Update the note in the view model
                        if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                            var updatedNote = viewModel.notes[index]
                            updatedNote.title = title.isEmpty ? "Untitled" : title
                            updatedNote.attributedContent = attributedText
                            viewModel.notes[index] = updatedNote
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty && attributedText.string.isEmpty)
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
