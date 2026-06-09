import SwiftUI

struct FavoriteLocationRow: View {
    let location: Location
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelect) {
                HStack {
                    Label(location.name, systemImage: "star.fill")
                        .font(.callout)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Remove \(location.name) from favorites"))
        }
        .padding(.vertical, LayoutConstants.Search.rowVerticalPadding)
        .padding(.horizontal, LayoutConstants.Search.rowHorizontalPadding)
    }
}
