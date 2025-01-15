import Foundation

public extension String {

    /// Splits the string into groups with a certain number of characters.
    /// - Parameter every: How many characters each group should have.
    /// - Returns: An array of strings where each string contains a group of `every` characters from the string.
    /// The last item may contain less than the specified number.
    func split(every: Int) -> [String] {
        var result = [String]()

        for i in stride(from: 0, to: self.count, by: every) {
            let startIndex = self.index(self.startIndex, offsetBy: i)
            let endIndex = self.index(startIndex, offsetBy: every, limitedBy: self.endIndex) ?? self.endIndex
            result.append(String(self[startIndex..<endIndex]))
        }

        return result
    }

}
