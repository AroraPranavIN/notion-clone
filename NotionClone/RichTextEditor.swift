import SwiftUI

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    @Binding var isUnderlined: Bool
    @Binding var textColor: UIColor?
    @Binding var backgroundColor: UIColor?
    @Binding var adjustFontSize: Int
    @Environment(\.colorScheme) var colorScheme

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.attributedText != parent.attributedText {
                parent.attributedText = textView.attributedText
                print("textViewDidChange: Updated attributedText with font size: \(textView.attributedText.fontSize(at: 0) ?? 0)")
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            if let selectedRange = textView.selectedTextRange {
                let nsRange = textView.nsRange(from: selectedRange)
                print("Selection changed: \(nsRange)")
                if nsRange.location < textView.attributedText.length {
                    let attributes = textView.attributedText.attributes(at: nsRange.location, effectiveRange: nil)
                    if let font = attributes[.font] as? UIFont {
                        parent.isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        parent.isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        parent.isUnderlined = (attributes[.underlineStyle] as? Int) == NSUnderlineStyle.single.rawValue
                    }
                    parent.textColor = attributes[.foregroundColor] as? UIColor
                    parent.backgroundColor = attributes[.backgroundColor] as? UIColor
                } else {
                    parent.isBold = false
                    parent.isItalic = false
                    parent.isUnderlined = false
                    parent.textColor = nil
                    parent.backgroundColor = nil
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
        textView.adjustsFontForContentSizeCategory = false
        
        // Set the default font size to 20 for better readability
        let defaultFontSize: CGFloat = 20
        let defaultFont = UIFont(name: "Helvetica", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
        var defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: defaultFont
        ]
        
        defaultAttributes[.foregroundColor] = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }
        
        // Set the typing attributes to ensure newly typed text uses the default font
        textView.typingAttributes = defaultAttributes
        print("makeUIView: Set typingAttributes with font size: \(defaultFontSize)")
        
        // Apply the default attributes to the attributedText
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: mutableText.length)
        
        // If the attributedText is empty or has no font, apply the default font
        var hasFont = false
        if mutableText.length > 0 {
            mutableText.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasFont = true
                    stop.pointee = true
                }
            }
        }
        
        if !hasFont {
            mutableText.addAttribute(.font, value: defaultFont, range: fullRange)
            print("makeUIView: Applied default font size \(defaultFontSize) to empty or font-less attributedText")
        } else {
            print("makeUIView: AttributedText already has a font, skipping default font application")
        }
        
        mutableText.addAttribute(.foregroundColor, value: defaultAttributes[.foregroundColor]!, range: fullRange)
        textView.attributedText = mutableText
        self.attributedText = mutableText // Update the binding to ensure consistency
        
        print("makeUIView: Initial font size: \(defaultFont.pointSize)")
        if mutableText.length > 0 {
            print("makeUIView: Actual font size after setup: \(mutableText.fontSize(at: 0) ?? 0)")
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        print("updateUIView called with textColor: \(String(describing: textColor)), backgroundColor: \(String(describing: backgroundColor))")
        
        let selectedRange = uiView.selectedTextRange
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        // Ensure the attributedText has the default font size if no font is specified
        let fullRange = NSRange(location: 0, length: mutableAttributedText.length)
        var hasFont = false
        if mutableAttributedText.length > 0 {
            mutableAttributedText.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasFont = true
                    stop.pointee = true
                }
            }
        }
        
        if !hasFont {
            let defaultFontSize: CGFloat = 20
            let defaultFont = UIFont(name: "Helvetica", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
            mutableAttributedText.addAttribute(.font, value: defaultFont, range: fullRange)
            print("updateUIView: Applied default font size \(defaultFontSize) to font-less attributedText")
            
            // Update typingAttributes to ensure new text uses the default font
            uiView.typingAttributes = [
                .font: defaultFont,
                .foregroundColor: UIColor { traitCollection in
                    switch traitCollection.userInterfaceStyle {
                    case .dark:
                        return .white
                    default:
                        return .black
                    }
                }
            ]
        }
        
        if let selectedRange = selectedRange, !selectedRange.isEmpty {
            var nsRange = uiView.nsRange(from: selectedRange)
            print("Selected range: \(nsRange)")
            
            if nsRange.location >= mutableAttributedText.length {
                nsRange = NSRange(location: max(0, mutableAttributedText.length - 1), length: 0)
            } else if nsRange.location + nsRange.length > mutableAttributedText.length {
                nsRange.length = mutableAttributedText.length - nsRange.location
            }
            
            var fontSize: CGFloat = 20 // Default to 20 if no font size is found
            var isCurrentlyBold = false
            var isCurrentlyItalic = false
            var isCurrentlyUnderlined = false
            var hasMixedBold = false
            var hasMixedItalic = false
            var hasMixedUnderline = false
            
            if nsRange.length > 0 {
                mutableAttributedText.enumerateAttributes(in: nsRange, options: []) { (attributes, range, stop) in
                    if let font = attributes[.font] as? UIFont {
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        let isUnderlined = (attributes[.underlineStyle] as? Int) == NSUnderlineStyle.single.rawValue
                        fontSize = font.pointSize
                        
                        if range.location == nsRange.location {
                            isCurrentlyBold = isBold
                            isCurrentlyItalic = isItalic
                            isCurrentlyUnderlined = isUnderlined
                        } else {
                            if isBold != isCurrentlyBold {
                                hasMixedBold = true
                            }
                            if isItalic != isCurrentlyItalic {
                                hasMixedItalic = true
                            }
                            if isUnderlined != isCurrentlyUnderlined {
                                hasMixedUnderline = true
                            }
                        }
                    }
                }
            }
            print("Current font size before formatting: \(fontSize)")
            print("Is currently bold: \(isCurrentlyBold), Has mixed bold: \(hasMixedBold)")
            print("Is currently italic: \(isCurrentlyItalic), Has mixed italic: \(hasMixedItalic)")
            print("Is currently underlined: \(isCurrentlyUnderlined), Has mixed underline: \(hasMixedUnderline)")
            
            let newBoldState = hasMixedBold ? isBold : (isBold != isCurrentlyBold ? !isCurrentlyBold : isCurrentlyBold)
            let newItalicState = hasMixedItalic ? isItalic : (isItalic != isCurrentlyItalic ? !isCurrentlyItalic : isCurrentlyItalic)
            let newUnderlineState = hasMixedUnderline ? isUnderlined : (isUnderlined != isCurrentlyUnderlined ? !isCurrentlyUnderlined : isCurrentlyUnderlined)
            
            self.isBold = newBoldState
            self.isItalic = newItalicState
            self.isUnderlined = newUnderlineState
            print("New bold state: \(newBoldState), New italic state: \(newItalicState), New underline state: \(newUnderlineState)")
            
            if adjustFontSize != 0 {
                fontSize = max(8, fontSize + CGFloat(adjustFontSize * 2))
                self.adjustFontSize = 0
            }
            
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
            
            if nsRange.location < mutableAttributedText.length && nsRange.length > 0 {
                mutableAttributedText.addAttribute(.font, value: newFont, range: nsRange)
                print("Applied font: \(newFont.fontName), size: \(newFont.pointSize)")
                
                if newUnderlineState {
                    mutableAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                    print("Applied underline")
                } else {
                    mutableAttributedText.removeAttribute(.underlineStyle, range: nsRange)
                    print("Removed underline")
                }
                
                if let textColor = textColor {
                    mutableAttributedText.addAttribute(.foregroundColor, value: textColor, range: nsRange)
                    print("Applied text color: \(textColor)")
                    // Update typingAttributes with the new text color
                    uiView.typingAttributes[.foregroundColor] = textColor
                }
                
                if let backgroundColor = backgroundColor {
                    mutableAttributedText.addAttribute(.backgroundColor, value: backgroundColor, range: nsRange)
                    print("Applied background color: \(backgroundColor)")
                    // Update typingAttributes with the new background color
                    uiView.typingAttributes[.backgroundColor] = backgroundColor
                } else {
                    mutableAttributedText.removeAttribute(.backgroundColor, range: nsRange)
                    print("Removed background color")
                    // Remove background color from typingAttributes
                    uiView.typingAttributes.removeValue(forKey: .backgroundColor)
                }
            } else {
                print("No valid range to apply attributes: \(nsRange)")
            }
            
            print("New font size after formatting: \(newFont.pointSize)")
            
            if mutableAttributedText != uiView.attributedText {
                uiView.attributedText = mutableAttributedText
                self.attributedText = mutableAttributedText
            }
            
            uiView.selectedTextRange = selectedRange
        } else {
            print("No selection to apply formatting")
            let defaultTextColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .white
                default:
                    return .black
                }
            }
            let mutableText = NSMutableAttributedString(attributedString: attributedText)
            let fullRange = NSRange(location: 0, length: mutableText.length)
            
            // Only apply default text color to ranges that lack a foregroundColor attribute
            var needsUpdate = false
            mutableText.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
                if value == nil {
                    mutableText.addAttribute(.foregroundColor, value: defaultTextColor, range: range)
                    needsUpdate = true
                }
            }
            
            if needsUpdate {
                if mutableText != uiView.attributedText {
                    uiView.attributedText = mutableText
                    self.attributedText = mutableText
                }
            }
        }
    }
}

extension UITextView {
    func nsRange(from textRange: UITextRange) -> NSRange {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSRange(location: location, length: length)
    }
}

extension NSAttributedString {
    static func == (lhs: NSAttributedString, rhs: NSAttributedString) -> Bool {
        if lhs.length != rhs.length {
            return false
        }
        if lhs.string != rhs.string {
            return false
        }
        
        let range = NSRange(location: 0, length: lhs.length)
        var isEqual = true
        
        lhs.enumerateAttributes(in: range, options: []) { (lhsAttrs, lhsRange, stop) in
            var rhsAttrs: [NSAttributedString.Key: Any] = [:]
            rhs.enumerateAttributes(in: lhsRange, options: []) { (attrs, range, innerStop) in
                if range == lhsRange {
                    rhsAttrs = attrs
                }
            }
            
            if lhsAttrs.count != rhsAttrs.count || lhsRange != lhsRange {
                isEqual = false
                stop.pointee = true
                return
            }
            
            for (key, lhsValue) in lhsAttrs {
                guard let rhsValue = rhsAttrs[key] else {
                    isEqual = false
                    stop.pointee = true
                    return
                }
                
                switch key {
                case .font:
                    if let lhsFont = lhsValue as? UIFont, let rhsFont = rhsValue as? UIFont {
                        if lhsFont != rhsFont {
                            isEqual = false
                            stop.pointee = true
                            return
                        }
                    } else {
                        isEqual = false
                        stop.pointee = true
                        return
                    }
                case .foregroundColor, .backgroundColor:
                    if let lhsColor = lhsValue as? UIColor, let rhsColor = rhsValue as? UIColor {
                        if lhsColor != rhsColor {
                            isEqual = false
                            stop.pointee = true
                            return
                        }
                    } else {
                        isEqual = false
                        stop.pointee = true
                        return
                    }
                case .underlineStyle:
                    if let lhsStyle = lhsValue as? Int, let rhsStyle = rhsValue as? Int {
                        if lhsStyle != rhsStyle {
                            isEqual = false
                            stop.pointee = true
                            return
                        }
                    } else {
                        isEqual = false
                        stop.pointee = true
                        return
                    }
                default:
                    if String(describing: lhsValue) != String(describing: rhsValue) {
                        isEqual = false
                        stop.pointee = true
                        return
                    }
                }
            }
        }
        
        return isEqual
    }
    
    // Helper to get the font size at a specific index
    func fontSize(at index: Int) -> CGFloat? {
        if index >= length {
            return nil
        }
        if let font = attribute(.font, at: index, effectiveRange: nil) as? UIFont {
            return font.pointSize
        }
        return nil
    }
}
