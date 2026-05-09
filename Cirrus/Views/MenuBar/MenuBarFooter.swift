import SwiftUI

struct MenuBarFooter: View {
    let lastUpdated: Date?
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 4) {
            if let lastUpdated {
                Text(lastUpdated, format: .relative(presentation: .named))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 2)
            }

            Button {
                openSettings()
                DispatchQueue.main.asyncAfter(deadline: .now() + LayoutConstants.Delay.settingsActivation) {
                    NSApp.activate(ignoringOtherApps: true)
                }
            } label: {
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
    MenuBarFooter(lastUpdated: Date().addingTimeInterval(-180))
        .frame(width: 320)
}
#endif
