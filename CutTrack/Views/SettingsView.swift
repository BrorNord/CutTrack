import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var health: HealthManager
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        NavigationStack {
            Form {
                Section("Extreme plan") {
                    LabeledContent("Food target", value: "1,894 kcal")
                    LabeledContent("Active target", value: "900–1,000 kcal")
                    LabeledContent("Protein guide", value: "150 g")
                }
                Section("Connections") {
                    Label(health.isAuthorized ? "Apple Health connected" : "Apple Health permission needed",
                          systemImage: health.isAuthorized ? "heart.fill" : "heart.slash")
                    Label(notifications.authorized ? "Notifications enabled" : "Notifications disabled",
                          systemImage: notifications.authorized ? "bell.fill" : "bell.slash")
                    Button("Refresh permissions") {
                        Task {
                            await health.requestAuthorization()
                            await notifications.requestPermission()
                        }
                    }
                }
                Section("How activity works") {
                    Text("CutTrack reads active energy and running workouts recorded by Apple Watch or another app through Apple Health.")
                    Text("Resting calories are not included in the 900–1,000 target.")
                }
                Section("Safety") {
                    Text("Wearable calorie estimates are approximate. Do not keep increasing exercise solely to hit a number when you are ill, injured or poorly recovered.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
