import XCTest
@testable import TokenTextView

class TokenTextViewMirror: MirrorObject {
    init(_ view: TokenTextView) {
        super.init(refrecting: view)
    }

    var tokenInstances: [TokenInstance]? {
        extract()
    }

    var pasteboardTokenInstances: [(TokenInstance, Int)]? {
        extract()
    }
}

final class TokenTextViewTests: XCTestCase {

    var mockPlainText: String!
    var mockTemplateText: String!
    var mockTokens: [TemplateToken]!
    var mockTokenInstances: [TokenInstance]!
    var tokenTextView: TokenTextView!
    var tokenTextViewMirror: TokenTextViewMirror!

    // MARK: Setup

    override func setUp() {
        loadMockData()
        tokenTextView = TokenTextView(text: mockTemplateText, tokenList: mockTokens)
        tokenTextViewMirror = TokenTextViewMirror(tokenTextView)
    }

    // MARK: Initialization

    func testInitWithTextAndTokens() {
        XCTAssertNotNil(tokenTextView)
    }

    func testInitWithTextNoTokens() {
        tokenTextView = TokenTextView(text: mockTemplateText)
        XCTAssertNotNil(tokenTextView)
    }

    func testInitWithNoTextNoTokens() {
        tokenTextView = TokenTextView()
        XCTAssertNotNil(tokenTextView)
    }

    func testInitWithTokensAndNoText() {
        tokenTextView = TokenTextView(tokenList: mockTokens)
        XCTAssertNotNil(tokenTextView)
    }

    // MARK: Tokenized text

    func testTokenizeText() {
        XCTAssertEqual(tokenTextView.string, mockPlainText)
    }

    func testTokenizeTextTokenInstanceRangesAreCorrect() {
        for instance in mockTokenInstances {
            guard let tokenInstance = tokenTextViewMirror.tokenInstances?.first(where: { $0.token.identifier == instance.token.identifier }) else {
                XCTFail()
                return
            }

            XCTAssertEqual(instance.range.location, tokenInstance.range.location)
            XCTAssertEqual(instance.range.length, tokenInstance.range.length)
        }
    }

    func testAddTokenUpdatesTokenInstances() {
        guard let token = mockTokens.first else {
            XCTFail()
            return
        }

        let numberOfTokenInstances = tokenTextViewMirror.tokenInstances?.count ?? 0

        tokenTextView.insertToken(token)

        XCTAssertEqual(tokenTextViewMirror.tokenInstances?.count ?? 0, numberOfTokenInstances + 1)
    }

    func testDeleteTokenTextRemovesTokenInstances() {
        guard let tokenRange = tokenTextViewMirror.tokenInstances?.last?.range else {
            XCTFail()
            return
        }

        tokenTextView.selectedRange = NSRange(location: tokenRange.upperBound, length: 0)
        let numberOfTokenInstances = tokenTextViewMirror.tokenInstances?.count ?? 0

        tokenTextView.deleteBackward(nil)

        XCTAssertEqual(tokenTextViewMirror.tokenInstances?.count, numberOfTokenInstances - 1)
    }

    // MARK: Templated text

    func testTemplatedTextComputeIsCorrect() {
        XCTAssertEqual(tokenTextView.templatedText, mockTemplateText)
    }

    // MARK: Keyboard updates

    func testInsertTextBeforeAllTokenInstancesUpdatesAllTokenInstanceRanges() {
        guard let staleTokenInstances = tokenTextViewMirror.tokenInstances?.map({ $0.copy() as? TokenInstance }) as? [TokenInstance] else {
            XCTFail("Could not get staleTokenInstances")
            return
        }
        let newText = "T"

        tokenTextView.selectedRange = NSRange(location: 0, length: 0)
        tokenTextView.insertText(
            newText,
            replacementRange: tokenTextView.string.fullRange
        )

        let invalidTokenInstances = tokenTextViewMirror.tokenInstances?.filter { instance in
            guard let staleTokenInstanceLocation = staleTokenInstances.first(where: { $0.token.identifier == instance.token.identifier })?.range.location else {
                XCTFail("Could not get staleTokenInstanceLocation")
                return false
            }
            return instance.range.location != staleTokenInstanceLocation + 1
        } ?? []

        XCTAssertTrue(invalidTokenInstances.isEmpty)
    }

    func testInsertTextAfterAllTokenInstancesDoesNotUpdateTokenInstanceRanges() {
        guard let staleTokenInstances = tokenTextViewMirror.tokenInstances?.map({ $0.copy() as? TokenInstance }) as? [TokenInstance] else {
            XCTFail("Could not get slateTokenInstances")
            return
        }
        let newText = "T"

        tokenTextView.selectedRange = NSRange(location: tokenTextView.string.count, length: 0)
        tokenTextView.insertText(
            newText,
            replacementRange: tokenTextView.string.fullRange
        )

        let invalidTokenInstances = tokenTextViewMirror.tokenInstances?.filter { instance in
            guard let staleTokenInstanceLocation = staleTokenInstances.first(where: { $0.token.identifier == instance.token.identifier })?.range.location else {
                XCTFail("Could not get staleTokenInstanceLocation")
                return false
            }
            return instance.range.location != staleTokenInstanceLocation
        } ?? []

        XCTAssertTrue(invalidTokenInstances.isEmpty)
    }

    /*func testInsertTextBetweenTokenInstancesUpdatesRangesAfterInsertion() {
        guard var staleTokenInstances = tokenTextViewMirror.tokenInstances?.map({ $0.copy() as? TokenInstance }) as? [TokenInstance] else {
            XCTFail("Could not get slateTokenInstances")
            return
        }
        staleTokenInstances.sort { $0.range.location < $1.range.location }
        let newText = "T"

        let insertLocation = (staleTokenInstances[staleTokenInstances.count].range.location) - 1
        tokenTextView.selectedRange = NSRange(location: insertLocation, length: 0)
        tokenTextView.insertText(newText)

        let invalidTokenInstances = tokenTextViewMirror.tokenInstances?.filter { instance in
            guard let staleTokenInstanceLocation = staleTokenInstances.first(where: { $0.token.identifier == instance.token.identifier })?.range.location else {
                XCTFail("Could not get staleTokenInstanceLocation")
                return false
            }

            return staleTokenInstanceLocation >= insertLocation ? instance.range.location != staleTokenInstanceLocation + 1 : staleTokenInstanceLocation != instance.range.location
        } ?? []

        XCTAssertTrue(invalidTokenInstances.isEmpty)
    }*/

    // MARK: Pasteboard operations

    func testCutPasteboardOperationCopiesTokenInstancesWithOffsetValue() {
        let cutRange = NSRange(location: 20, length: 80)
        let selectedToken = tokenTextViewMirror.tokenInstances?.filter { $0.range.upperBound <= cutRange.upperBound && $0.range.location >= cutRange.location }
        tokenTextView.selectedRange = cutRange
        tokenTextView.cut(tokenTextView)

        XCTAssertEqual(tokenTextViewMirror.pasteboardTokenInstances?.count, selectedToken?.count)
        XCTAssertEqual(tokenTextViewMirror.pasteboardTokenInstances?.first?.1, (selectedToken?.first?.range.location ?? 0) - cutRange.location)
    }

    func testCopyPasteboardOperationCopiesTokenInstancesWithOffsetValue() {
        let copyRange = NSRange(location: 20, length: 80)
        let selectedToken = tokenTextViewMirror.tokenInstances?.filter { $0.range.upperBound <= copyRange.upperBound && $0.range.location >= copyRange.location }
        tokenTextView.selectedRange = copyRange
        tokenTextView.copy(tokenTextView)

        XCTAssertEqual(tokenTextViewMirror.pasteboardTokenInstances?.count, selectedToken?.count)
        XCTAssertEqual(tokenTextViewMirror.pasteboardTokenInstances?.first?.1, (selectedToken?.first?.range.location ?? 0) - copyRange.location)
    }

    func testPastePasteboardOperationAddsNewTokenInstanceRanges() {
        let copyRange = NSRange(location: 20, length: 80)
        let staleInstanceCount = tokenTextViewMirror.tokenInstances?.count ?? 0
        tokenTextView.selectedRange = copyRange
        tokenTextView.copy(tokenTextView)

        let pasteRange = NSRange(location: tokenTextView.string.count, length: 0)
        tokenTextView.selectedRange = pasteRange
        tokenTextView.paste(tokenTextView)

        let newTokenInstance = tokenTextViewMirror.tokenInstances?.first(where: { $0.range.location == pasteRange.location + (tokenTextViewMirror.pasteboardTokenInstances?.first?.1 ?? 0) })
        XCTAssertNotNil(newTokenInstance)
        XCTAssertEqual(tokenTextViewMirror.tokenInstances?.count, staleInstanceCount + 1)
    }

    func testPastePasteboardOperationUpdatesRangesAfterPaste() {
        guard let staleTokenInstances = tokenTextViewMirror.tokenInstances?.map({ $0.copy() as? TokenInstance }) as? [TokenInstance] else {
            XCTFail("Could not get slateTokenInstances")
            return
        }

        let copyRange = NSRange(location: 20, length: 80)
        tokenTextView.selectedRange = copyRange
        tokenTextView.copy(tokenTextView)

        let pasteRange = NSRange(location: 118, length: 0)
        tokenTextView.selectedRange = pasteRange
        tokenTextView.paste(tokenTextView)

        let invalidTokenInstances = tokenTextViewMirror.tokenInstances?.filter { instance in
            guard let staleTokenInstanceLocation = staleTokenInstances.first(where: { $0.token.identifier == instance.token.identifier })?.range.location else {
                XCTFail("Could not get staleTokenInstanceLocation")
                return false
            }

            return staleTokenInstanceLocation >= pasteRange.location ? instance.range.location != staleTokenInstanceLocation + copyRange.length : staleTokenInstanceLocation != instance.range.location
        } ?? []

        XCTAssertEqual(invalidTokenInstances.count, 1)
    }

}

// MARK: Load data

extension TokenTextViewTests {

    private func loadMockData() {
        if let path = Bundle.module.path(forResource: "MockTokens", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONDecoder().decode([TemplateToken].self, from: jsonData)
                self.mockTokens = jsonResult
            } catch {
                print("Could not decode Tokens.json")
                XCTFail()
            }
        }
        if let path = Bundle.module.path(forResource: "MockTokenInstances", ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData) as? [[String: [String: AnyObject]]]
                var mockTokenInstances = [TokenInstance]()
                for object in jsonResult! {
                    guard let name = object["token"]?["name"] as? String else {
                        continue
                    }
                    guard let identifier = object["token"]?["identifier"] as? String else {
                        continue
                    }
                    guard let location = object["range"]?["location"] as? Int else {
                        continue
                    }
                    guard let length = object["range"]?["length"] as? Int else {
                        continue
                    }
                    mockTokenInstances.append(TokenInstance(token: TemplateToken(name: name, identifier: identifier), range: NSRange(location: location, length: length)))
                }
                self.mockTokenInstances = mockTokenInstances
            } catch {
                print("Could not decode MockInstancesTokens.json")
                XCTFail()
            }
        }
        if let path = Bundle.module.path(forResource: "MockTemplateText", ofType: "txt") {
            do {
                mockTemplateText = try String(contentsOfFile: path)
            } catch {
                print("Could not read MockTemplateText.txt")
                XCTFail()
            }
        }
        if let path = Bundle.module.path(forResource: "MockPlainText", ofType: "txt") {
            do {
                mockPlainText = try String(contentsOfFile: path)
            } catch {
                print("Could not read MockPlainText.txt")
                XCTFail()
            }
        }
    }

}
