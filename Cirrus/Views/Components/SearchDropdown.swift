import SwiftUI

struct SearchDropdown: View {
    let isPinnedLocation: Bool
    let hasSearchQuery: Bool
    @ObservedObject var searchViewModel: LocationSearchViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    var onSelectLocation: (Location) -> Void
    var onUseCurrentLocation: () -> Void
    var onToggleFavorite: (Location) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isPinnedLocation {
                Button(action: onUseCurrentLocation) {
                    Label(String(localized: "Current Location"), systemImage: "location.fill")
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, LayoutConstants.Search.rowVerticalPadding)
                        .padding(.horizontal, LayoutConstants.Search.rowHorizontalPadding)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            if !settingsViewModel.favoriteLocations.isEmpty && !hasSearchQuery {
                if isPinnedLocation { Divider() }
                ForEach(settingsViewModel.favoriteLocations) { location in
                    FavoriteLocationRow(
                        location: location,
                        onSelect: { onSelectLocation(location) },
                        onRemove: { settingsViewModel.removeFavorite(location) }
                    )
                }
            }

            if (isPinnedLocation || !settingsViewModel.favoriteLocations.isEmpty)
                && (!searchViewModel.results.isEmpty || hasSearchQuery) {
                Divider()
            }

            if searchViewModel.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                        .controlSize(.small)
                    Spacer()
                }
                .padding(.vertical, LayoutConstants.Search.rowVerticalPadding)
            }

            if !searchViewModel.isSearching && searchViewModel.results.isEmpty && hasSearchQuery {
                Text(String(localized: "No results found"))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LayoutConstants.Search.rowVerticalPadding)
            }

            ForEach(searchViewModel.results) { location in
                SearchDropdownRow(
                    location: location,
                    isFavorite: settingsViewModel.isFavorite(location),
                    onSelect: { onSelectLocation(location) },
                    onToggleFavorite: { onToggleFavorite(location) }
                )
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
