import SwiftUI

struct NoteDetailView: View {
    @ObservedObject var viewModel: NoteViewModel
    let note: Note
    
    var body: some View {
        NavigationStack { // Changed from NavigationView to NavigationStack
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(note.title)
                        .font(.title)
                        .padding(.horizontal)
                    
                    // Display the attributed content
                    AttributedTextView(attributedText: note.attributedContent)
                        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Add a button to edit the note
                    NavigationLink(destination: EditNoteView(viewModel: viewModel, note: note)) {
                        Text("Edit Note")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(note.title)
        }
    }
}

// A simple view to display NSAttributedString using UILabel
struct AttributedTextView: UIViewRepresentable {
    let attributedText: NSAttributedString
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let label = UILabel()
        
        label.numberOfLines = 0 // Allow multiple lines
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(label)
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        
        // Set up constraints for the label within the scroll view
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16) // Ensure the label width matches the scroll view width minus padding
        ])
        
        updateLabel(label)
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let label = uiView.subviews.first as? UILabel {
            updateLabel(label)
        }
    }
    
    private func updateLabel(_ label: UILabel) {
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: mutableText.length)
        
        // Reapply the background color to ensure compatibility
        mutableText.enumerateAttribute(.backgroundColor, in: fullRange, options: []) { (value, range, stop) in
            if let color = value as? UIColor {
                let newColor = UIColor(cgColor: color.cgColor)
                mutableText.removeAttribute(.backgroundColor, range: range)
                mutableText.addAttribute(.backgroundColor, value: newColor, range: range)
                print("Reapplied background color \(newColor) in range \(range)")
            }
        }
        
        label.attributedText = mutableText
        
        // Debug the attributed text to confirm background color and text color
        mutableText.enumerateAttribute(.backgroundColor, in: fullRange, options: []) { (value, range, stop) in
            if let color = value as? UIColor {
                print("AttributedTextView: Displaying background color \(color) in range \(range)")
            }
        }
        mutableText.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
            if let color = value as? UIColor {
                print("AttributedTextView: Displaying text color \(color) in range \(range)")
            }
        }
    }
}

struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(viewModel: NoteViewModel(), note: Note(title: "Sample Note", attributedContent: NSAttributedString(string: "Sample content")))
    }
}
