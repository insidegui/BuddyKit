import Foundation
import BuddyPathKit

public extension FilePath {
    init(_ url: URL) {
        if #available(iOS 16.0, macCatalyst 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self.init(url.absoluteURL.path(percentEncoded: false))
        } else {
            self.init(url.absoluteURL.path)
        }
    }
}
