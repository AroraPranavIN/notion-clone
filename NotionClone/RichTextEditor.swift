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
                let range = NSRange(location: 0, length: textView.attributedText.length)
                textView.attributedText.enumerateAttribute(.backgroundColor, in: range, options: []) { (value, range, stop) in
                    if let color = value as? UIColor {
                        print("textViewDidChange: Found background color \(color) in range \(range)")
                    }
                }
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
                    if let currentTextColor = attributes[.foregroundColor] as? UIColor {
                        parent.textColor = currentTextColor
                    }
                    if let currentBackgroundColor = attributes[.backgroundColor] as? UIColor {
                        parent.backgroundColor = currentBackgroundColor
                    }
                    print("Updated textColor from selection: \(String(describing: parent.textColor))")
                    print("Updated backgroundColor from selection: \(String(describing: parent.backgroundColor))")
                } else {
                    parent.isBold = false
                    parent.isItalic = false
                    parent.isUnderlined = false
                    print("No attributes to update from selection")
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
        
        let defaultFontSize: CGFloat = 20
        let defaultFont = UIFont(name: "Helvetica", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
        let defaultTextColor = colorScheme == .dark ? UIColor.white : UIColor.black
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: defaultFont,
            .foregroundColor: defaultTextColor
        ]
        
        textView.typingAttributes = defaultAttributes
        print("makeUIView: Set typingAttributes with font size: \(defaultFontSize), textColor: \(defaultTextColor)")
        
        let mutableText = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: mutableText.length)
        
        var hasFont = false
        var hasTextColor = false
        if mutableText.length > 0 {
            mutableText.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasFont = true
                    stop.pointee = true
                }
            }
            mutableText.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasTextColor = true
                    stop.pointee = true
                }
            }
        }
        
        if !hasFont {
            mutableText.addAttribute(.font, value: defaultFont, range: fullRange)
            print("makeUIView: Applied default font size \(defaultFontSize) to empty or font-less attributedText")
        }
        if !hasTextColor {
            mutableText.addAttribute(.foregroundColor, value: defaultTextColor, range: fullRange)
            print("makeUIView: Applied default text color \(defaultTextColor) to empty or color-less attributedText")
        }
        
        textView.attributedText = mutableText
        self.attributedText = mutableText
        
        print("makeUIView: Initial font size: \(defaultFont.pointSize)")
        if mutableText.length > 0 {
            print("makeUIView: Actual font size after setup: \(mutableText.fontSize(at: 0) ?? 0)")
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        print("updateUIView called with textColor: \(String(describing: textColor)), backgroundColor: \(String(describing: backgroundColor)), adjustFontSize: \(adjustFontSize)")
        
        let selectedRange = uiView.selectedTextRange
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        let fullRange = NSRange(location: 0, length: mutableAttributedText.length)
        var hasFont = false
        var hasTextColor = false
        if mutableAttributedText.length > 0 {
            mutableAttributedText.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasFont = true
                    stop.pointee = true
                }
            }
            mutableAttributedText.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
                if value != nil {
                    hasTextColor = true
                    stop.pointee = true
                }
            }
        }
        
        let defaultTextColor = colorScheme == .dark ? UIColor.white : UIColor.black
        if !hasFont {
            let defaultFontSize: CGFloat = 20
            let defaultFont = UIFont(name: "Helvetica", size: defaultFontSize) ?? UIFont.systemFont(ofSize: defaultFontSize)
            mutableAttributedText.addAttribute(.font, value: defaultFont, range: fullRange)
            print("updateUIView: Applied default font size \(defaultFontSize) to font-less attributedText")
            
            uiView.typingAttributes = [
                .font: defaultFont,
                .foregroundColor: defaultTextColor
            ]
        }
        // Only apply default text color if no foregroundColor is set
        if !hasTextColor {
            mutableAttributedText.addAttribute(.foregroundColor, value: defaultTextColor, range: fullRange)
            print("updateUIView: Applied default text color \(defaultTextColor) to color-less attributedText")
        }
        
        if let selectedRange = selectedRange, !selectedRange.isEmpty {
            var nsRange = uiView.nsRange(from: selectedRange)
            print("Selected range: \(nsRange)")
            
            if nsRange.location >= mutableAttributedText.length {
                nsRange = NSRange(location: max(0, mutableAttributedText.length - 1), length: 0)
            } else if nsRange.location + nsRange.length > mutableAttributedText.length {
                nsRange.length = mutableAttributedText.length - nsRange.location
            }
            
            var fontSize: CGFloat = 20
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
            let newUnderlineState = hasMixedUnderline ? isUnderlined : (isUnderlined != isCurrentlyUnderlined ? !isUnderlined : isCurrentlyUnderlined)
            
            self.isBold = newBoldState
            self.isItalic = newItalicState
            self.isUnderlined = newUnderlineState
            print("New bold state: \(newBoldState), New italic state: \(newItalicState), New underline state: \(newUnderlineState)")
            
            // Apply font size adjustment
            if adjustFontSize != 0 {
                fontSize = max(8, fontSize + CGFloat(adjustFontSize * 2))
                print("Adjusted font size to: \(fontSize)")
                self.adjustFontSize = 0 // Reset after applying
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
                
                // Apply underline
                if newUnderlineState {
                    mutableAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                    uiView.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    print("Applied underline to range: \(nsRange)")
                } else {
                    mutableAttributedText.removeAttribute(.underlineStyle, range: nsRange)
                    uiView.typingAttributes.removeValue(forKey: .underlineStyle)
                    print("Removed underline from range: \(nsRange)")
                }
                
                // Apply text color
                if let textColor = textColor {
                    let compatibleTextColor = UIColor(cgColor: textColor.cgColor)
                    mutableAttributedText.addAttribute(.foregroundColor, value: compatibleTextColor, range: nsRange)
                    uiView.typingAttributes[.foregroundColor] = compatibleTextColor
                    print("Applied text color: \(compatibleTextColor) to range: \(nsRange)")
                }
                
                // Apply background color
                if let backgroundColor = backgroundColor {
                    let compatibleBackgroundColor = UIColor(cgColor: backgroundColor.cgColor)
                    mutableAttributedText.addAttribute(.backgroundColor, value: compatibleBackgroundColor, range: nsRange)
                    uiView.typingAttributes[.backgroundColor] = compatibleBackgroundColor
                    print("Applied background color: \(compatibleBackgroundColor) to range: \(nsRange)")
                } else {
                    mutableAttributedText.removeAttribute(.backgroundColor, range: nsRange)
                    uiView.typingAttributes.removeValue(forKey: .backgroundColor)
                    print("Removed background color from range: \(nsRange)")
                }
            } else {
                print("No valid range to apply attributes: \(nsRange)")
                if let textColor = textColor {
                    let compatibleTextColor = UIColor(cgColor: textColor.cgColor)
                    uiView.typingAttributes[.foregroundColor] = compatibleTextColor
                    print("Set typingAttributes text color: \(compatibleTextColor)")
                } else {
                    uiView.typingAttributes[.foregroundColor] = defaultTextColor
                    print("Set typingAttributes text color to default: \(defaultTextColor)")
                }
                
                if let backgroundColor = backgroundColor {
                    let compatibleBackgroundColor = UIColor(cgColor: backgroundColor.cgColor)
                    uiView.typingAttributes[.backgroundColor] = compatibleBackgroundColor
                    print("Set typingAttributes background color: \(compatibleBackgroundColor)")
                } else {
                    uiView.typingAttributes.removeValue(forKey: .backgroundColor)
                    print("Cleared typingAttributes background color")
                }
                
                if isUnderlined {
                    uiView.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                    print("Set typingAttributes underline")
                } else {
                    uiView.typingAttributes.removeValue(forKey: .underlineStyle)
                    print("Cleared typingAttributes underline")
                }
                
                uiView.typingAttributes[.font] = newFont
                print("Set typingAttributes font size: \(newFont.pointSize)")
            }
            
            print("New font size after formatting: \(newFont.pointSize)")
            
            if mutableAttributedText != uiView.attributedText {
                uiView.attributedText = mutableAttributedText
                self.attributedText = mutableAttributedText
                print("Updated attributedText with formatting")
                mutableAttributedText.enumerateAttribute(.backgroundColor, in: fullRange, options: []) { (value, range, stop) in
                    if let color = value as? UIColor {
                        print("Final attributedText has background color \(color) in range \(range)")
                    }
                }
                mutableAttributedText.enumerateAttribute(.foregroundColor, in: fullRange, options: []) { (value, range, stop) in
                    if let color = value as? UIColor {
                        print("Final attributedText has text color \(color) in range \(range)")
                    }
                }
            }
            
            uiView.selectedTextRange = selectedRange
        } else {
            print("No selection to apply formatting")
            let mutableText = NSMutableAttributedString(attributedString: attributedText)
            
            if let backgroundColor = backgroundColor {
                let compatibleBackgroundColor = UIColor(cgColor: backgroundColor.cgColor)
                uiView.typingAttributes[.backgroundColor] = compatibleBackgroundColor
                print("Set typingAttributes background color (no selection): \(compatibleBackgroundColor)")
            } else {
                uiView.typingAttributes.removeValue(forKey: .backgroundColor)
                print("Cleared typingAttributes background color (no selection)")
            }
            
            if let textColor = textColor {
                let compatibleTextColor = UIColor(cgColor: textColor.cgColor)
                uiView.typingAttributes[.foregroundColor] = compatibleTextColor
                print("Set typingAttributes text color (no selection): \(compatibleTextColor)")
            } else {
                uiView.typingAttributes[.foregroundColor] = defaultTextColor
                print("Set typingAttributes text color to default (no selection): \(defaultTextColor)")
            }
            
            if isUnderlined {
                uiView.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                print("Set typingAttributes underline (no selection)")
            } else {
                uiView.typingAttributes.removeValue(forKey: .underlineStyle)
                print("Cleared typingAttributes underline (no selection)")
            }
            
            if adjustFontSize != 0 {
                let defaultFontSize: CGFloat = 20
                let newFontSize = max(8, defaultFontSize + CGFloat(adjustFontSize * 2))
                let newFont = UIFont(name: "Helvetica", size: newFontSize) ?? UIFont.systemFont(ofSize: newFontSize)
                uiView.typingAttributes[.font] = newFont
                print("Set typingAttributes font size (no selection): \(newFontSize)")
                self.adjustFontSize = 0
            }
            
            if mutableText != uiView.attributedText {
                uiView.attributedText = mutableText
                self.attributedText = mutableText
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
