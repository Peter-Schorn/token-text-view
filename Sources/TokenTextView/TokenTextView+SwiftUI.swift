import SwiftUI

@available(macOS 10.15, *)
public struct TokenTextViewSwiftUI: NSViewRepresentable {

    @Binding var string: String

    let tokens: [TemplateToken]

    public init(
        string: Binding<String>,
        tokens: [TemplateToken]
    ) {
        self._string = string
        self.tokens = tokens
    }

    public func makeNSView(context: Context) -> TokenTextView {
        let view = TokenTextView(
            text: self.string,
            tokenList: self.tokens
        )
        return view
    }

    public func updateNSView(_ nsView: TokenTextView, context: Context) {
        let string = self.string
        if nsView.string != string {
            nsView.string = string
        }
    }

}

@available(macOS 10.15, *)
struct SwiftUIView_Previews: PreviewProvider {

    @State static private var string = ""
    static let tokens = [
        TemplateToken(name: "one", identifier: "one"),
        TemplateToken(name: "two", identifier: "two"),
        TemplateToken(name: "three", identifier: "three")
    ]

    static var previews: some View {
        TokenTextViewSwiftUI(
            string: Self.$string,
            tokens: Self.tokens
        )
    }

}
