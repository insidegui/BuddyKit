#if os(macOS)
import AppKit

public extension NSPasteboard {
    var string: String? {
        get { string(forType: .string) }
        set {
            clearContents()
            guard let newValue else { return }
            setString(newValue, forType: .string)
        }
    }
}
#endif // os(macOS)
