import SwiftUI

struct MenuBarFooter: View {
    var body: some View {
        VStack(spacing: 4) {
            SettingsLink {
                Label(String(localized: "Settings..."), systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MenuBarButtonStyle())

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label(String(localized: "Quit Cirrus"), systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MenuBarButtonStyle())
        }
        .padding(LayoutConstants.Padding.footer)
    }
}

#if DEBUG
#Preview {
    MenuBarFooter()
        .frame(width: 320)
}
#endif
