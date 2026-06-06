import SwiftUI

struct MenuBarFooter: View {
    let lastUpdated: Date?
    let attributionName: String?
    let attributionURL: URL?
    @ObservedObject var updaterViewModel: UpdaterViewModel
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 4) {
            if lastUpdated != nil || attributionName != nil {
                HStack(spacing: 0) {
                    if let lastUpdated {
                        Text(lastUpdated, format: .relative(presentation: .named))
                    }
                    if lastUpdated != nil && attributionName != nil {
                        Text(" · ")
                    }
                    if let name = attributionName, let url = attributionURL {
                        Link(name, destination: url)
                            .foregroundStyle(.tertiary)
                    }
                }
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
                updaterViewModel.checkForUpdates()
            } label: {
                Label(String(localized: "Check for Updates..."), systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(MenuBarButtonStyle())
            .disabled(!updaterViewModel.canCheckForUpdates)

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
    MenuBarFooter(
        lastUpdated: Date().addingTimeInterval(-180),
        attributionName: "Open-Meteo.com",
        attributionURL: URL(string: "https://open-meteo.com"),
        updaterViewModel: UpdaterViewModel()
    )
    .frame(width: 320)
}
#endif
