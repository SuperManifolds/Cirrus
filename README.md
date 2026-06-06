# Cirrus

A lightweight, native macOS menu bar weather app. Built with SwiftUI.

## Features

- **Menu bar presence** — current weather at a glance with configurable display (icon, temperature, condition)
- **Dual weather providers** — Open-Meteo (free) and Apple WeatherKit, switchable in settings
- **Detailed popover** — current conditions, 24-hour hourly forecast, 10-day daily forecast
- **Smart detail cards** — wind, humidity, UV, pressure, cloud cover, visibility, dew point, snow depth, sunrise/sunset — shown only when relevant, with sparklines and visual indicators
- **Minute-level precipitation** — MET Norway radar nowcast for Nordic countries, Open-Meteo elsewhere, WeatherKit where supported
- **Air quality & pollen** — AQI, PM2.5, PM10, and 6 pollen types via Open-Meteo
- **AI weather summary** — on-device natural language summary using Apple Foundation Models
- **Severe weather alerts** — banner notifications with expandable details
- **Location search** — auto-detect via CoreLocation or manual city search with favorites
- **Locale-aware units** — temperature, wind, pressure, visibility all formatted per system locale
- **macOS notifications** — severe weather, rain warnings, pollen alerts
- **Disk-cached data** — instant relaunch with previously fetched weather
- **Accessibility** — VoiceOver labels, reduced motion support, grouped composite views

## Install

Download the latest DMG from [Releases](https://github.com/SuperManifolds/Cirrus/releases), open it, and drag Cirrus to your Applications folder.

## Requirements

- macOS 26.4 or later (Apple Silicon)
- Location Services (optional, for auto-detect)
- Apple Intelligence (optional, for AI weather summary)
- Apple Developer membership (optional, for WeatherKit provider)

## Building

```bash
git clone https://github.com/SuperManifolds/Cirrus.git
cd Cirrus
open Cirrus.xcodeproj
```

Select your development team, then build and run.

### WeatherKit Setup

To use the WeatherKit provider, enable the WeatherKit capability in both the **Capabilities** and **App Services** tabs in the Apple Developer Portal for your bundle ID.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Data Sources

- [Open-Meteo](https://open-meteo.com) — free weather data (CC BY 4.0)
- [Apple WeatherKit](https://developer.apple.com/weatherkit/) — Apple Weather data
- [MET Norway](https://api.met.no) — radar-based precipitation nowcast for Nordic countries
- [Open-Meteo Air Quality API](https://open-meteo.com/en/docs/air-quality-api) — AQI and pollen data (CAMS)

## License

MIT
