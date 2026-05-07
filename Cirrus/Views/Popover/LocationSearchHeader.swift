import SwiftUI

struct LocationSearchHeader: View {
    let locationName: String
    @ObservedObject var searchViewModel: LocationSearchViewModel
    var onLocationSelected: (Location) -> Void
    @State private var isSearching = false

    var body: some View {
        if isSearching {
            VStack(spacing: 6) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "Search city..."), text: $searchViewModel.searchText)
                        .textFieldStyle(.plain)
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

                if searchViewModel.isSearching {
                    ProgressView()
                        .controlSize(.small)
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
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            Button {
                isSearching = true
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
}

#if DEBUG
#Preview {
    LocationSearchHeader(
        locationName: "Oslo",
        searchViewModel: LocationSearchViewModel(locationProvider: MockLocationProvider()),
        onLocationSelected: { _ in }
    )
    .frame(width: 320)
    .padding()
}
#endif
