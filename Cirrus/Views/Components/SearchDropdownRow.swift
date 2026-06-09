import SwiftUI

struct SearchDropdownRow: View {
    let location: Location
    let isFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelect) {
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(isFavorite ? .yellow : .secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                isFavorite
                    ? String(localized: "Remove from favorites")
                    : String(localized: "Add to favorites")
            )
        }
        .padding(.vertical, LayoutConstants.Search.rowVerticalPadding)
        .padding(.horizontal, LayoutConstants.Search.rowHorizontalPadding)
    }
}
