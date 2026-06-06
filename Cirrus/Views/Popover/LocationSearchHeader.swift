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

    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "Search city..."), text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
                        .focused($isTextFieldFocused)
                    Button {
                        isSearching = false
                        searchViewModel.clearResults()
                    } label: {
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
                        HStack(spacing: 4) {
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
                        Button {
                            onRefresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11))
                                .foregroundStyle(.tertiary)
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
                searchResults
                    .offset(y: LayoutConstants.Offset.searchDropdown)
            }
        }
        .zIndex(1)
    }

    private var hasSearchQuery: Bool {
        searchViewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    private var hasDropdownContent: Bool {
        !searchViewModel.results.isEmpty || searchViewModel.isSearching
            || hasSearchQuery || !settingsViewModel.favoriteLocations.isEmpty
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isPinnedLocation {
                Button {
                    onUseCurrentLocation()
                    isSearching = false
                    searchViewModel.clearResults()
                } label: {
                    Label(String(localized: "Current Location"), systemImage: "location.fill")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if !settingsViewModel.favoriteLocations.isEmpty && !hasSearchQuery {
                if isPinnedLocation { Divider() }
                ForEach(settingsViewModel.favoriteLocations) { location in
                    Button {
                        onLocationSelected(location)
                        isSearching = false
                        searchViewModel.clearResults()
                    } label: {
                        HStack {
                            Label(location.name, systemImage: "star.fill")
                                .font(.callout)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            if isPinnedLocation || !settingsViewModel.favoriteLocations.isEmpty {
                if !searchViewModel.results.isEmpty || hasSearchQuery { Divider() }
            }

            if searchViewModel.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            if !searchViewModel.isSearching && searchViewModel.results.isEmpty && hasSearchQuery {
                Text(String(localized: "No results found"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }

            ForEach(searchViewModel.results) { location in
                Button {
                    onLocationSelected(location)
                    isSearching = false
                    searchViewModel.clearResults()
                } label: {
                    HStack {
                        Text(location.name)
                            .font(.callout)
                        if let area = location.administrativeArea {
                            Text(area)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(LayoutConstants.Padding.card)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.card)
                .fill(.ultraThickMaterial)
                .shadow(
                    color: .black.opacity(LayoutConstants.Opacity.searchShadow),
                    radius: LayoutConstants.Opacity.searchShadowRadius,
                    y: LayoutConstants.Opacity.searchShadowY
                )
        )
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
