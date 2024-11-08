import SwiftData
import Foundation
internal import BuddyFoundation

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension ModelContainer {

    /// Creates a copy of the on-disk representation that can be opened with a database app.
    /// - Returns: URL to temporary database file that can be opened with a database app.
    ///
    /// This method finds the first configuration of the container that's stored on disk, then copies the database files
    /// to a temporary location, replacing the `.store` extension with `.db` so that the database can be opened for inspection
    /// with most SQLite-editing applications, such as TablePlus.
    func createInspectableDatabaseCopy() throws -> URL {
        guard let config = configurations.first(where: { !$0.isStoredInMemoryOnly }) else {
            throw "Couldn't find any exportable configuration."
        }

        let outputDir = URL(filePath: NSTemporaryDirectory())
        let namePrefix = Bundle.main.bestEffortName

        let storeFileURL = config.url
        let shmFileURL = URL(filePath: config.url.path + "-shm")
        let walFileURL = URL(filePath: config.url.path + "-wal")

        let fileNameToken = Int(Date.now.timeIntervalSinceReferenceDate)
        let outputStoreFileName = namePrefix + "-\(fileNameToken)-" + storeFileURL.lastPathComponent.replacingOccurrences(of: ".store", with: ".db")
        let outputSHMFileName = namePrefix + "-\(fileNameToken)-" + shmFileURL.lastPathComponent.replacingOccurrences(of: ".store", with: ".db")
        let outputWALFileName = namePrefix + "-\(fileNameToken)-" + walFileURL.lastPathComponent.replacingOccurrences(of: ".store", with: ".db")

        let outputStoreFileURL = outputDir.appending(path: outputStoreFileName)
        let outputSHMFileURL = outputDir.appending(path: outputSHMFileName)
        let outputWALFileURL = outputDir.appending(path: outputWALFileName)

        guard FileManager.default.fileExists(atPath: storeFileURL.path) else {
            throw "Store file doesn't exist at \(storeFileURL.path)"
        }

        try FileManager.default.copyItem(at: storeFileURL, to: outputStoreFileURL)
        if FileManager.default.fileExists(atPath: shmFileURL.path) {
            try FileManager.default.copyItem(at: shmFileURL, to: outputSHMFileURL)
        }
        if FileManager.default.fileExists(atPath: walFileURL.path) {
            try FileManager.default.copyItem(at: walFileURL, to: outputWALFileURL)
        }

        return outputStoreFileURL
    }
}

