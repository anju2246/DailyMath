import Foundation

/// Generic JSON-file-backed persistence for arrays of Codable entities.
/// Each store writes to its own file under `Application Support/DailyMath/`.
final class LocalStore<Entity: Codable & Identifiable> where Entity.ID: Hashable {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "dailymath.localstore", attributes: .concurrent)
    private var cache: [Entity] = []

    init(filename: String) {
        let fm = FileManager.default
        let base = (try? fm.url(for: .applicationSupportDirectory,
                                in: .userDomainMask,
                                appropriateFor: nil,
                                create: true)) ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("DailyMath", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        self.fileURL = dir.appendingPathComponent("\(filename).json")
        self.cache = Self.load(from: fileURL)
    }

    // MARK: - Public API

    func all() -> [Entity] {
        queue.sync { cache }
    }

    func find(where predicate: (Entity) -> Bool) -> Entity? {
        queue.sync { cache.first(where: predicate) }
    }

    func filter(_ predicate: (Entity) -> Bool) -> [Entity] {
        queue.sync { cache.filter(predicate) }
    }

    func upsert(_ entity: Entity) {
        queue.sync(flags: .barrier) {
            if let idx = cache.firstIndex(where: { $0.id == entity.id }) {
                cache[idx] = entity
            } else {
                cache.append(entity)
            }
            persist()
        }
    }

    func delete(id: Entity.ID) {
        queue.sync(flags: .barrier) {
            cache.removeAll { $0.id == id }
            persist()
        }
    }

    func deleteAll(where predicate: (Entity) -> Bool) {
        queue.sync(flags: .barrier) {
            cache.removeAll(where: predicate)
            persist()
        }
    }

    func replace(with entities: [Entity]) {
        queue.sync(flags: .barrier) {
            cache = entities
            persist()
        }
    }

    var isEmpty: Bool {
        queue.sync { cache.isEmpty }
    }

    // MARK: - Private

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(cache)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[LocalStore] persist error: \(error)")
        }
    }

    private static func load(from url: URL) -> [Entity] {
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Entity].self, from: data)) ?? []
    }
}
