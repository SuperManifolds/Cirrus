import Foundation

protocol PollenProviding: Sendable {
    func fetchPollen(for location: Location) async throws -> Pollen?
}

// MARK: - Mock

#if DEBUG
struct MockPollenProvider: PollenProviding {
    func fetchPollen(for location: Location) async throws -> Pollen? {
        Pollen(
            alder: 5,
            birch: 45,
            grass: 80,
            mugwort: 0,
            olive: 0,
            ragweed: 0,
            timestamp: Date()
        )
    }
}
#endif
