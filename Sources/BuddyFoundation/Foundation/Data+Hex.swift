import Foundation

public extension Data {

    /// Returns a hex-encoded string representing the contents of the data.
    ///
    /// The hex string is uppercased, with each byte being composed of two characters.
    ///
    /// **Example:**
    ///
    /// ```
    /// 537461792068756E6772792C207374617920666F6F6C697368
    /// ```
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
