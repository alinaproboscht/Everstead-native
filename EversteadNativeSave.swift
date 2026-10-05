import Foundation

// MARK: - EVERSTEAD 0.32
// Native save envelope. The actual EversteadGame snapshot can be added once
// the existing GameModels types conform to Codable.

struct EversteadNativeSave: Codable {
    static let formatVersion = 1

    var formatVersion: Int = Self.formatVersion
    var savedAt: Date = Date()
    var simulation: EversteadVillageSimulation
}

enum EversteadNativeSaveStore {
    private static let fileManager = FileManager.default

    static var folder: URL {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("Everstead", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    static var saveURL: URL {
        folder.appendingPathComponent("everstead-native.json")
    }

    static func save(_ simulation: EversteadVillageSimulation) throws {
        let envelope = EversteadNativeSave(simulation: simulation)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(envelope).write(to: saveURL, options: .atomic)
    }

    static func load() throws -> EversteadNativeSave {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(
            EversteadNativeSave.self,
            from: Data(contentsOf: saveURL)
        )
    }
}
