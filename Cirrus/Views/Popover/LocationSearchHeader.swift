import SwiftUI

struct LocationSearchHeader: View {
    let locationName: String
    let isPinnedLocation: Bool
    @ObservedObject var searchViewModel: LocationSearchViewModel
    var onLocationSelected: (Location) -> Void
    var onUseCurrentLocation: () -> Void
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
                .padding(LayoutConstants.CornerRadius.searchField)
                .background(
                    .primary.opacity(LayoutConstants.Opacity.searchFieldBackground),
                    in: RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.searchField)
                )
            } else {
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
            }
        }
        .overlay(alignment: .top) {
            if isSearching && (!searchViewModel.results.isEmpty || isPinnedLocation || searchViewModel.isSearching) {
                searchResults
                    .offset(y: 36)
            }
        }
        .zIndex(1)
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

                if !searchViewModel.results.isEmpty {
                    Divider()
                }
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
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        )
    }
}

#if DEBUG
#Preview("Default") {
    LocationSearchHeader(
        locationName: "Oslo",
        isPinnedLocation: false,
        searchViewModel: LocationSearchViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {}
    )
    .frame(width: 320)
    .padding()
}

#Preview("Pinned") {
    LocationSearchHeader(
        locationName: "Bergen",
        isPinnedLocation: true,
        searchViewModel: LocationSearchViewModel.preview(),
        onLocationSelected: { _ in },
        onUseCurrentLocation: {}
    )
    .frame(width: 320)
    .padding()
}
#endif
