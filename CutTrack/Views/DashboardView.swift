import SwiftUI
import SwiftData

struct DashboardView: View {
    @EnvironmentObject private var health: HealthManager
    @EnvironmentObject private var liveActivity: LiveActivityManager
    @Query(sort: \FoodEntry.createdAt, order: .reverse) private var food: [FoodEntry]

    private var todayFood: [FoodEntry] {
        food.filter { Calendar.current.isDateInToday($0.createdAt) }
    }
    private var eaten: Double { todayFood.reduce(0) { $0 + $1.calories } }
    private var protein: Double { todayFood.reduce(0) { $0 + $1.protein } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CUTTRACK").font(.caption.bold()).tracking(3).foregroundStyle(.secondary)
                            Text("Extreme").font(.largeTitle.bold())
                        }
                        Spacer()
                        Button { Task { await health.refreshToday() } } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3.bold()).padding(12)
                                .background(.thinMaterial, in: Circle())
                        }
                    }

                    HStack(spacing: 14) {
                        GoalRing(progress: eaten / Goals.foodCalories, value: "\(Int(eaten))", label: "food", footer: "1,894 kcal")
                        GoalRing(progress: health.activeCalories / Goals.activeMinimum, value: "\(Int(health.activeCalories))", label: "active", footer: "900–1,000 kcal")
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))

                    HStack(spacing: 10) {
                        MetricCard(title: "Remaining", value: "\(Int(Goals.foodCalories - eaten))", unit: "kcal")
                        MetricCard(title: "Running", value: "\(Int(health.runningMinutes))", unit: "minutes")
                        MetricCard(title: "Protein", value: "\(Int(protein))", unit: "grams")
                    }

                    targetStatus

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today").font(.title2.bold())
                        Label("Food target is not increased when you exercise.", systemImage: "checkmark.shield.fill")
                        Label("Apple Watch active energy updates through HealthKit.", systemImage: "applewatch")
                        Label("Runs recorded in Workout automatically count.", systemImage: "figure.run")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))

                    Button {
                        Task {
                            if liveActivity.running {
                                await liveActivity.end()
                            } else {
                                await liveActivity.start(food: Int(eaten), active: Int(health.activeCalories))
                            }
                        }
                    } label: {
                        Label(liveActivity.running ? "Stop Live Activity" : "Start Live Activity", systemImage: "livephoto")
                            .frame(maxWidth: .infinity).padding().fontWeight(.bold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .task {
                await health.refreshToday()
                SharedSnapshot.save(food: Int(eaten), active: Int(health.activeCalories))
            }
            .onChange(of: eaten) { _, newValue in
                SharedSnapshot.save(food: Int(newValue))
                Task { await liveActivity.update(food: Int(newValue), active: Int(health.activeCalories)) }
            }
            .refreshable { await health.refreshToday() }
        }
    }

    @ViewBuilder
    private var targetStatus: some View {
        let active = health.activeCalories
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: active >= Goals.activeMinimum ? "checkmark.circle.fill" : "flame.fill")
                .font(.title2)
                .foregroundStyle(active >= Goals.activeMinimum ? .green : .orange)
            VStack(alignment: .leading, spacing: 4) {
                Text(active >= Goals.activeMinimum ? "Active target reached" : "\(Int(Goals.activeMinimum - active)) active kcal remaining")
                    .font(.headline)
                Text(active > Goals.activeMaximum
                     ? "You are above the planned range. Prioritise recovery rather than chasing a larger number."
                     : "Walking, running, cycling and normal daily movement all contribute.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
    }
}

private struct GoalRing: View {
    let progress: Double
    let value: String
    let label: String
    let footer: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().stroke(.white.opacity(0.1), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: min(max(progress, 0), 1))
                    .stroke(.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 1) {
                    Text(value).font(.title2.bold())
                    Text(label.uppercased()).font(.caption2.bold()).tracking(1.5).foregroundStyle(.secondary)
                }
            }
            .frame(height: 130)
            Text(footer).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.bold())
            Text(unit).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
