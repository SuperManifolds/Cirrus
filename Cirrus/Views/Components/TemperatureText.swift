import SwiftUI

struct TemperatureText: View {
    let measurement: Measurement<UnitTemperature>
    let unit: TemperatureUnit
    var font: Font = .body

    var body: some View {
        Text(measurement.formatted(as: unit))
            .font(font)
            .monospacedDigit()
    }
}

#if DEBUG
#Preview {
    VStack {
        TemperatureText(
            measurement: Measurement(value: 22, unit: .celsius),
            unit: .celsius,
            font: .largeTitle
        )
        TemperatureText(
            measurement: Measurement(value: 22, unit: .celsius),
            unit: .fahrenheit,
            font: .body
        )
    }
    .padding()
}
#endif
