import AppKit
import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel

    private var symbolName: String {
        if let current = weatherViewModel.snapshot?.current {
            return current.condition.symbol(isDaytime: current.isDaytime)
        }
        return "cloud.sun.fill"
    }

    var body: some View {
        HStack(spacing: 4) {
            if settingsViewModel.coloredMenuBarIcon {
                Image(nsImage: coloredIcon)
            } else {
                Image(systemName: symbolName)
                    .symbolRenderingMode(.monochrome)
            }

            switch settingsViewModel.menuBarDisplayMode {
                case .iconOnly:
                    EmptyView()
                case .iconAndTemperature:
                    if let temp = weatherViewModel.snapshot?.current.temperature {
                        Text(temp.formatted(as: settingsViewModel.temperatureUnit))
                    }
                case .iconTemperatureAndCondition:
                    if let current = weatherViewModel.snapshot?.current {
                        let temp = current.temperature.formatted(as: settingsViewModel.temperatureUnit)
                        Text("\(temp) \(current.condition.displayName)")
                    }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(menuBarAccessibilityLabel)
    }

    private var menuBarAccessibilityLabel: String {
        guard let current = weatherViewModel.snapshot?.current else {
            return String(localized: "Cirrus Weather")
        }
        let temp = current.temperature.formatted(as: settingsViewModel.temperatureUnit)
        return "\(temp), \(current.condition.displayName)"
    }

    private var coloredIcon: NSImage {
        guard let base = NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: "Weather"
        ) else {
            return NSImage()
        }
        let config = NSImage.SymbolConfiguration(paletteColors: [iconColor])
        let image = base.withSymbolConfiguration(config) ?? base
        image.isTemplate = false
        return image
    }

    private var iconColor: NSColor {
        guard let current = weatherViewModel.snapshot?.current else {
            return .secondaryLabelColor
        }
        switch current.condition {
            case .clear, .mainlyClear:
                return current.isDaytime ? .systemYellow : .systemPurple
            case .partlyCloudy:
                return .systemBlue
            case .rain, .heavyRain, .showers, .heavyShowers, .drizzle:
                return .systemCyan
            case .snow, .heavySnow, .snowShowers, .sleet, .freezingDrizzle, .freezingRain:
                return .systemTeal
            case .thunderstorm, .thunderstormWithHail:
                return .systemOrange
            case .cloudy, .fog:
                return .secondaryLabelColor
        }
    }
}

#if DEBUG
#Preview("Icon + Temp") {
    MenuBarLabel(
        weatherViewModel: WeatherViewModel.preview(),
        settingsViewModel: {
            let vm = SettingsViewModel()
            vm.menuBarDisplayMode = .iconAndTemperature
            return vm
        }()
    )
    .padding()
}

#Preview("Icon + Temp + Condition") {
    MenuBarLabel(
        weatherViewModel: WeatherViewModel.preview(),
        settingsViewModel: {
            let vm = SettingsViewModel()
            vm.menuBarDisplayMode = .iconTemperatureAndCondition
            return vm
        }()
    )
    .padding()
}
#endif
