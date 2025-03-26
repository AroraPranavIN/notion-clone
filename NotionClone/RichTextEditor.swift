import SwiftUI

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.attributedText = textView.attributedText
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            // Update the toggle states based on the selected text's attributes
            if let selectedRange = textView.selectedTextRange {
                let nsRange = textView.nsRange(from: selectedRange)
                if nsRange.location < textView.attributedText.length {
                    let attributes = textView.attributedText.attributes(at: nsRange.location, effectiveRange: nil)
                    if let font = attributes[.font] as? UIFont {
                        parent.isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        parent.isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        print("Selected font size: \(font.pointSize)") // Debug log
                    }
                } else {
                    parent.isBold = false
                    parent.isItalic = false
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.delegate = context.coordinator
        // Disable Dynamic Type scaling
        textView.adjustsFontForContentSizeCategory = false
        // Set the default font with a specific size
        let defaultFont = UIFont(name: "Helvetica", size: 16) ?? UIFont.systemFont(ofSize: 16)
        let defaultAttributes: [NSAttributedString.Key: Any] = [.font: defaultFont]
        textView.attributedText = NSAttributedString(string: attributedText.string, attributes: defaultAttributes)
        print("Initial font size in makeUIView: \(defaultFont.pointSize)") // Debug log
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Store the current selection
        let selectedRange = uiView.selectedTextRange
        
        // Update the attributed text
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // If there's a selection, apply formatting to the selected range
        if let selectedRange = selectedRange, !selectedRange.isEmpty {
            var nsRange = uiView.nsRange(from: selectedRange)
            
            // Validate the range to ensure it doesn't exceed the string length
            if nsRange.location >= mutableAttributedText.length {
                nsRange = NSRange(location: max(0, mutableAttributedText.length - 1), length: 0)
            } else if nsRange.location + nsRange.length > mutableAttributedText.length {
                nsRange.length = mutableAttributedText.length - nsRange.location
            }
            
            // Check the formatting across the entire selected range
            var fontSize: CGFloat = 16
            var isCurrentlyBold = false
            var isCurrentlyItalic = false
            var hasMixedBold = false
            var hasMixedItalic = false
            
            if nsRange.length > 0 {
                mutableAttributedText.enumerateAttribute(.font, in: nsRange, options: []) { (value, range, stop) in
                    if let font = value as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        fontSize = font.pointSize // Use the font size from the first character
                        
                        // Check for mixed formatting
                        if range.location == nsRange.location {
                            isCurrentlyBold = isBold
                            isCurrentlyItalic = isItalic
                        } else {
                            if isBold != isCurrentlyBold {
                                hasMixedBold = true
                            }
                            if isItalic != isCurrentlyItalic {
                                hasMixedItalic = true
                            }
                        }
                    }
                }
            }
            print("Current font size before formatting: \(fontSize)") // Debug log
            print("Is currently bold: \(isCurrentlyBold), Has mixed bold: \(hasMixedBold)") // Debug log
            print("Is currently italic: \(isCurrentlyItalic), Has mixed italic: \(hasMixedItalic)") // Debug log
            
            // Toggle the formatting based on the current state
            // If there's mixed formatting, pressing the button will apply the formatting to the entire range
            let newBoldState = hasMixedBold ? isBold : (isBold != isCurrentlyBold ? !isCurrentlyBold : isCurrentlyBold)
            let newItalicState = hasMixedItalic ? isItalic : (isItalic != isCurrentlyItalic ? !isCurrentlyItalic : isCurrentlyItalic)
            
            // Update the binding states to reflect the new state
            self.isBold = newBoldState
            self.isItalic = newItalicState
            print("New bold state: \(newBoldState), New italic state: \(newItalicState)") // Debug log
            
            // Determine the new font based on the toggled states using Helvetica
            let newFont: UIFont
            switch (newBoldState, newItalicState) {
            case (true, true):
                newFont = UIFont(name: "Helvetica-BoldOblique", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            case (true, false):
                newFont = UIFont(name: "Helvetica-Bold", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            case (false, true):
                newFont = UIFont(name: "Helvetica-Oblique", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            case (false, false):
                newFont = UIFont(name: "Helvetica", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
            }
            
            // Apply the new font to the selected range
            if nsRange.location < mutableAttributedText.length {
                mutableAttributedText.addAttribute(.font, value: newFont, range: nsRange)
            }
            print("New font size after formatting: \(newFont.pointSize)") // Debug log
            
            // Update the text view's attributed text
            uiView.attributedText = mutableAttributedText
            self.attributedText = mutableAttributedText
            
            // Restore the selection
            uiView.selectedTextRange = selectedRange
        } else {
            // If there's no selection, just update the text without changing formatting
            uiView.attributedText = attributedText
        }
    }
}

// Extension to convert UITextRange to NSRange
extension UITextView {
    func nsRange(from textRange: UITextRange) -> NSRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSRange(location: location, length: length)
    }
}
