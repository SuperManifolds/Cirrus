import AppIntents

struct CirrusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentWeather(),
            phrases: [
                "What's the weather in \(.applicationName)",
                "Current weather in \(.applicationName)",
                "How's the weather \(.applicationName)"
            ],
            shortTitle: "Current Weather",
            systemImageName: "cloud.sun.fill"
        )
        AppShortcut(
            intent: GetTemperature(),
            phrases: [
                "What's the temperature in \(.applicationName)",
                "How hot is it \(.applicationName)",
                "How cold is it \(.applicationName)"
            ],
            shortTitle: "Temperature",
            systemImageName: "thermometer.medium"
        )
        AppShortcut(
            intent: GetForecast(),
            phrases: [
                "What's the forecast in \(.applicationName)",
                "Today's weather in \(.applicationName)",
                "Weather forecast \(.applicationName)"
            ],
            shortTitle: "Forecast",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: WillItRain(),
            phrases: [
                "Will it rain \(.applicationName)",
                "Is it going to rain \(.applicationName)",
                "Do I need an umbrella \(.applicationName)"
            ],
            shortTitle: "Will It Rain",
            systemImageName: "cloud.rain.fill"
        )
    }
}
