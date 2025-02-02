import AppKit

public struct TokenTextViewAttributes {
    public var backgroundColor: NSColor
    public var foregroundColor: NSColor
    public var font: NSFont
    public var kern: Int?
    public var paragraphStyle: NSMutableParagraphStyle?

    public var dictionary: [NSAttributedString.Key: Any] {
        var dictionary = [NSAttributedString.Key.backgroundColor: backgroundColor,
                          NSAttributedString.Key.foregroundColor: foregroundColor,
                          NSAttributedString.Key.font: font,
                          NSAttributedString.Key.kern: kern != nil ? kern as Any : 0 as Any ]

        if let paragraphStyle = paragraphStyle {
            dictionary[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        }

        return dictionary
    }

    public init(backgroundColor: NSColor, foregroundColor: NSColor, font: NSFont, kern: Int? = nil, paragraphStyle: NSMutableParagraphStyle? = nil) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.font = font
        self.kern = kern
        self.paragraphStyle = paragraphStyle
    }
}
