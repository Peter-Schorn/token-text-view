import Foundation

extension Notification.Name {

    static let tokenTextDidChange = Self("tokenTextDidChange")

}

extension String {

    var fullRange: NSRange {
        NSRange(location: 0, length: self.count)
    }

}
