import SwiftUI

struct LocationSearchHeader: View {
    let locationName: String
    let isPinnedLocation: Bool
    @ObservedObject var searchViewModel: LocationSearchViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    var onLocationSelected: (Location) -> Void
    var onUseCurrentLocation: () -> Void
    var onRefresh: () -> Void
    var isLoading: Bool
    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool

    private var hasSearchQuery: Bool {
        searchViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).count
            >= LayoutConstants.Search.minQueryLength
    }

    private var hasDropdownContent: Bool {
        !searchViewModel.results.isEmpty || searchViewModel.isSearching
            || hasSearchQuery || !settingsViewModel.favoriteLocations.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "Search city..."), text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                    Button(action: dismissSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(LayoutConstants.Padding.searchField)
                .background(
                    .primary.opacity(LayoutConstants.Opacity.searchFieldBackground),
                    in: RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.searchField)
                )
            } else {
                ZStack {
                    Button {
                        isSearching = true
                        isTextFieldFocused = true
                    } label: {
                        HStack(spacing: LayoutConstants.Search.locationChevronSpacing) {
                            Text(locationName)
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Location: \(locationName)"))
                    .accessibilityHint(String(localized: "Double-tap to search for a location"))

                    HStack {
                        Spacer()
                        Button(action: onRefresh) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: LayoutConstants.Search.refreshIconSize))
                                .foregroundStyle(.tertiary)
                                .padding(.trailing, LayoutConstants.Search.refreshTrailingPadding)
                                .rotationEffect(.degrees(isLoading ? 360 : 0))
                                .animation(
                                    isLoading
                                        ? .linear(duration: 1).repeatForever(autoreverses: false)
                                        : .default,
                                    value: isLoading
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                        .accessibilityLabel(String(localized: "Refresh weather"))
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if isSearching && (hasDropdownContent || isPinnedLocation) {
                SearchDropdown(
                    isPinnedLocation: isPinnedLocation,
                    hasSearchQuery: hasSearchQuery,
                    searchViewModel: searchViewModel,
                    settingsViewModel: settingsViewModel,
                    onSelectLocation: { selectLocation($0) },
                    onUseCurrentLocation: useCurrentLocation,
                    onToggleFavorite: { toggleFavorite($0) }
                )
                .offset(y: LayoutConstants.Offset.searchDropdown)
            }
        }
        .zIndex(1)
    }

    private func dismissSearch() {
        isSearching = false
        searchViewModel.clearResults()
    }

    private func selectLocation(_ location: Location) {
        onLocationSelected(location)
        dismissSearch()
    }

    private func useCurrentLocation() {
        onUseCurrentLocation()
        dismissSearch()
    }

    private func toggleFavorite(_ location: Location) {
        if settingsViewModel.isFavorite(location) {
            settingsViewModel.removeFavorite(location)
        } else {
            settingsViewModel.addFavorite(location)
        }
    }
}

#if DEBUG
#Preview("Default") {
    LocationSearchHeader(
        locationName: "Oslo",
        isPinnedLocation: false,
        searchViewModel: LocationSearchViewModel.preview(),
        settingsViewModel: SettingsViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {},
        onRefresh: {},
        isLoading: false
    )
    .frame(width: 320)
    .padding()
}

#Preview("Pinned") {
    LocationSearchHeader(
        locationName: "Bergen",
        isPinnedLocation: true,
        searchViewModel: LocationSearchViewModel.preview(),
        settingsViewModel: SettingsViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {},
        onRefresh: {},
        isLoading: false
    )
    .frame(width: 320)
    .padding()
}
#endif
