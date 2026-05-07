import Combine
import Foundation

@MainActor
final class LocationSearchViewModel: ObservableObject {
    @Published var searchText = "" {
        didSet { scheduleSearch() }
    }
    @Published private(set) var results: [Location] = []
    @Published private(set) var isSearching = false
    @Published private(set) var error: String?

    private let locationProvider: any LocationProviding
    private var searchTask: Task<Void, Never>?

    init(locationProvider: any LocationProviding) {
        self.locationProvider = locationProvider
    }

    func clearResults() {
        results = []
        searchText = ""
        error = nil
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 2 else {
            results = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            isSearching = true
            do {
                results = try await locationProvider.search(query: query)
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
            isSearching = false
        }
    }

    #if DEBUG
    static func preview() -> LocationSearchViewModel {
        LocationSearchViewModel(locationProvider: MockLocationProvider())
    }
    #endif
}
