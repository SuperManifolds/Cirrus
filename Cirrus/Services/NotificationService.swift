import Foundation
import OSLog
import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private var isAuthorized = false

    override init() {
        super.init()
        center.delegate = self
        Task { await requestPermission() }
    }

    private func requestPermission() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            Log.weather.error("Notification permission failed: \(error.localizedDescription)")
        }
    }

    func postWeatherAlert(_ alert: WeatherAlert) {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = alert.event
        content.body = alert.headline
        content.sound = alert.severity == .extreme || alert.severity == .severe ? .default : nil
        post(content, id: "weather-alert-\(alert.id)")
    }

    func postRainWarning(summary: String) {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Rain Expected")
        content.body = summary
        content.sound = nil
        post(content, id: "rain-warning")
    }

    func postPollenAlert(type: String, level: PollenLevel) {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Pollen Alert")
        content.body = String(localized: "\(type): \(level.displayName)")
        content.sound = level == .veryHigh ? .default : nil
        post(content, id: "pollen-\(type)")
    }

    private func post(_ content: UNMutableNotificationContent, id: String) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        center.add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner])
    }
}
