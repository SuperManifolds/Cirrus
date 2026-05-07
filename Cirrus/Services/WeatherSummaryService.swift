import Foundation
import FoundationModels
import OSLog

@MainActor
final class WeatherSummaryService {
    private var session: LanguageModelSession?

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    func generateSummary(
        from snapshot: WeatherSnapshot,
        airQuality: AirQuality?,
        pollen: Pollen?,
        unit: TemperatureUnit
    ) async -> String? {
        guard isAvailable else {
            Log.weather.debug("AI summary skipped: model not available")
            return nil
        }

        let prompt = buildPrompt(from: snapshot, airQuality: airQuality, pollen: pollen, unit: unit)
        Log.weather.debug("AI summary prompt length: \(prompt.count) chars")

        do {
            let session = LanguageModelSession {
                """
                You write brief weather summaries for a menubar app. \
                Do not mention the location name. \
                Describe conditions naturally like "Cloudy, clearing around 15:00" \
                or "Rain throughout the morning, drying up by afternoon". \
                Focus on what changes and when. One sentence. No emoji. \
                No percentages. Mention pollen or air quality only if poor.
                """
            }

            let response = try await session.respond(
                to: prompt,
                generating: WeatherSummaryResult.self
            )

            let summary = response.content.summary
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !summary.isEmpty else { return nil }

            Log.weather.debug("AI summary: \(summary)")
            return summary
        } catch {
            Log.weather.error("AI summary failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func buildPrompt(
        from snapshot: WeatherSnapshot,
        airQuality: AirQuality?,
        pollen: Pollen?,
        unit: TemperatureUnit
    ) -> String {
        var lines: [String] = []
        lines.append("Location: \(snapshot.location.name)")

        let current = snapshot.current
        let temp = current.temperature.formatted(as: unit)
        let wind = current.windSpeed.formattedWindSpeed
        lines.append("Now: \(temp), \(current.condition.displayName), Wind \(wind)")

        lines.append("Hourly:")
        for hour in snapshot.hourly {
            let hr = hour.date.formatted(.dateTime.hour())
            let tm = hour.temperature.formatted(as: unit)
            let precip = Int(hour.precipitationProbability)
            lines.append("\(hr): \(tm) \(hour.condition.displayName) \(precip)%rain")
        }

        if let minutely = snapshot.minutely,
           minutely.contains(where: { $0.precipitationIntensity > 0 }) {
            let rates = minutely.map {
                $0.precipitationIntensity.formatted(
                    .number.precision(.fractionLength(1))
                )
            }.joined(separator: ",")
            lines.append("Precip next hour (mm/h): \(rates)")
        }

        if let aq = airQuality, aq.aqi > 40 {
            lines.append("Air Quality: AQI \(aq.aqi) (\(aq.aqiCategory.displayName))")
        }

        if let pollen {
            let notable: [(String, Double?)] = [
                ("Birch", pollen.birch), ("Grass", pollen.grass),
                ("Alder", pollen.alder), ("Mugwort", pollen.mugwort),
                ("Olive", pollen.olive), ("Ragweed", pollen.ragweed)
            ]
            let active = notable.compactMap { name, val -> String? in
                guard let amount = val, amount >= 10 else { return nil }
                return "\(name) \(Int(amount))"
            }
            if !active.isEmpty {
                lines.append("Pollen: \(active.joined(separator: ", "))")
            }
        }

        return lines.joined(separator: "\n")
    }
}

@Generable
struct WeatherSummaryResult {
    @Guide(description: "A concise 1-2 sentence weather summary for the day")
    let summary: String
}
