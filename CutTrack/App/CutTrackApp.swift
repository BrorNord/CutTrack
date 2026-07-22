import SwiftUI
import SwiftData

@main
struct CutTrackApp: App {
    @StateObject private var health = HealthManager()
    @StateObject private var notifications = NotificationManager()
    @StateObject private var liveActivity = LiveActivityManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(health)
                .environmentObject(notifications)
                .environmentObject(liveActivity)
                .task {
                    await health.requestAuthorization()
                    await health.refreshToday()
                    await notifications.requestPermission()
                    await notifications.scheduleSmartReminders()
                }
        }
        .modelContainer(for: [FoodEntry.self, WeightEntry.self, WorkoutEntry.self])
    }
}
