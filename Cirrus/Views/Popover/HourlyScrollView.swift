import SwiftUI

struct HourlyScrollView: View {
    let forecasts: [HourlyForecast]
    let unit: TemperatureUnit
    @State private var selectedForecast: HourlyForecast?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(Array(forecasts.enumerated()), id: \.element.id) { index, forecast in
                        HourlyForecastRow(forecast: forecast, unit: unit, isNow: index == 0)
                            .opacity(selectedForecast == nil || selectedForecast?.id == forecast.id ? 1 : 0.5)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedForecast = selectedForecast?.id == forecast.id ? nil : forecast
                                }
                            }
                    }
                }
                .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
            }
            .frame(height: LayoutConstants.Size.hourlyScrollHeight)

            if let selected = selectedForecast {
                HourlyDetailRow(forecast: selected, unit: unit)
                    .transition(.opacity)
            }
        }
    }
}

struct HourlyDetailRow: View {
    let forecast: HourlyForecast
    let unit: TemperatureUnit

    var body: some View {
        HStack(spacing: LayoutConstants.Spacing.cardGrid) {
            detailItem(
                icon: "wind",
                value: forecast.windSpeed.formattedWindSpeed
            )
            if let cloud = forecast.cloudCover {
                detailItem(icon: "cloud.fill", value: "\(Int(cloud))%")
            }
            if let uv = forecast.uvIndex, uv >= 1, forecast.isDaytime {
                detailItem(icon: "sun.max.fill", value: "\(Int(uv))")
            }
            if let dp = forecast.dewPoint {
                detailItem(icon: "drop.degreesign.fill", value: dp.formatted(as: unit))
            }
            if let pressure = forecast.pressure {
                detailItem(icon: "gauge.medium", value: pressure.formattedPressure)
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.vertical, 4)
        .padding(.horizontal, LayoutConstants.Padding.sectionHorizontal)
    }

    private func detailItem(icon: String, value: String) -> some View {
        Label(value, systemImage: icon)
            .labelStyle(.titleAndIcon)
    }
}

#if DEBUG
#Preview {
    let forecasts = MockWeatherProvider.mockHourly()
    HourlyScrollView(forecasts: forecasts, unit: .celsius)
        .frame(width: 320)
}
#endif
