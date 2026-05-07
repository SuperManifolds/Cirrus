import Foundation
import Testing
@testable import Cirrus

@MainActor
struct LocationSearchViewModelTests {

    @Test func shortQueryClearsResults() async {
        let vm = LocationSearchViewModel(locationProvider: MockLocationProvider())
        vm.searchText = "O"

        try? await Task.sleep(for: .milliseconds(50))
        #expect(vm.results.isEmpty)
    }

    @Test func clearResultsResetsState() async {
        let vm = LocationSearchViewModel(locationProvider: MockLocationProvider())
        vm.searchText = "Oslo"
        try? await Task.sleep(for: .milliseconds(400))

        vm.clearResults()

        #expect(vm.searchText.isEmpty)
        #expect(vm.results.isEmpty)
        #expect(vm.error == nil)
    }

    @Test func searchReturnsResults() async throws {
        let vm = LocationSearchViewModel(locationProvider: MockLocationProvider())
        vm.searchText = "Oslo"

        // Wait for debounce (300ms) + execution
        try await Task.sleep(for: .milliseconds(500))

        #expect(!vm.results.isEmpty)
        #expect(vm.results.first?.name == "Oslo")
    }

    @Test func emptyQueryAfterSearchClearsResults() async throws {
        let vm = LocationSearchViewModel(locationProvider: MockLocationProvider())
        vm.searchText = "Oslo"
        try await Task.sleep(for: .milliseconds(500))
        #expect(!vm.results.isEmpty)

        vm.searchText = ""
        try await Task.sleep(for: .milliseconds(50))
        #expect(vm.results.isEmpty)
    }
}
