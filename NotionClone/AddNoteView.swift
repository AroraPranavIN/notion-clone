import SwiftUI

struct AddNoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var attributedContent: NSAttributedString = NSAttributedString(string: "")
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var isUnderlined: Bool = false
    @State private var textColor: UIColor? = nil
    @State private var backgroundColor: UIColor? = nil
    @State private var adjustFontSize: Int = 0
    @State private var showingAddNote: Bool = false
    @State private var showingTextColorPicker: Bool = false
    @State private var showingBackgroundColorPicker: Bool = false
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Add Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newNote = Note(
                            title: title.isEmpty ? "Untitled Note" : title,
                            attributedContent: attributedContent
                        )
                        viewModel.addNote(newNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty && attributedContent.string.isEmpty)
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
