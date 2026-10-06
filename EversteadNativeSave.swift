import Foundation

// MARK: - EVERSTEAD 0.37
// Public native save envelope for EversteadCore.

public struct EversteadNativeSave: Codable, Sendable {
    public static let formatVersion = 1

    public var formatVersion: Int
    public var savedAt: Date
    public var simulation: EversteadVillageSimulation

    public init(
        formatVersion: Int = Self.formatVersion,
        savedAt: Date = Date(),
        simulation: EversteadVillageSimulation
    ) {
        self.formatVersion = formatVersion
        self.savedAt = savedAt
        self.simulation = simulation
    }
}

public enum EversteadNativeSaveStore {
    private static let fileManager = FileManager.default

    public static var folder: URL {
        let base = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("Everstead", isDirectory: true)

        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(
                at: folder,
                withIntermediateDirectories: true
            )
        }
        return folder
    }

    public static var saveURL: URL {
        folder.appendingPathComponent("everstead-native.json")
    }

    public static func save(_ simulation: EversteadVillageSimulation) throws {
        let envelope = EversteadNativeSave(simulation: simulation)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(envelope).write(to: saveURL, options: .atomic)
    }

    public static func load() throws -> EversteadNativeSave {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(
            EversteadNativeSave.self,
            from: Data(contentsOf: saveURL)
        )
    }
}
