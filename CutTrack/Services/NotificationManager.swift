import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    @Published var authorized = false

    func requestPermission() async {
        do {
            authorized = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            authorized = false
        }
    }

    func scheduleSmartReminders() async {
        guard authorized else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: ["cuttrack-morning", "cuttrack-afternoon", "cuttrack-evening"]
        )

        await schedule(
            id: "cuttrack-morning",
            hour: 8,
            title: "Plan today’s movement",
            body: "A run or brisk walk early makes the 900 active-calorie target easier."
        )
        await schedule(
            id: "cuttrack-afternoon",
            hour: 16,
            title: "Activity check",
            body: "Open CutTrack to see whether you are on pace for 900–1,000 active calories."
        )
        await schedule(
            id: "cuttrack-evening",
            hour: 20,
            title: "Finish the day",
            body: "Check your food budget, active calories and running progress."
        )
    }

    private func schedule(id: String, hour: Int, title: String, body: String) async {
        var components = DateComponents()
        components.hour = hour

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
