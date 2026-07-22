import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var health: HealthManager

    let template: WorkoutTemplate

    @State private var startedAt = Date()
    @State private var elapsed = 0
    @State private var running = true
    @State private var timer: Timer?
    @State private var activeCaloriesText = ""
    @State private var distanceText = ""
    @State private var notes = ""
    @State private var showFinish = false

    private var currentRound: WorkoutRound? {
        guard !template.rounds.isEmpty else { return nil }
        let cycle = template.rounds.reduce(0) { $0 + $1.seconds }
        guard cycle > 0 else { return nil }
        var position = elapsed % cycle
        for round in template.rounds {
            if position < round.seconds { return round }
            position -= round.seconds
        }
        return template.rounds.last
    }

    private var secondsRemainingInRound: Int? {
        guard !template.rounds.isEmpty else { return nil }
        let cycle = template.rounds.reduce(0) { $0 + $1.seconds }
        var position = elapsed % cycle
        for round in template.rounds {
            if position < round.seconds { return round.seconds - position }
            position -= round.seconds
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: template.kind.symbol)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(.green)

                Text(template.title)
                    .font(.title.bold())

                Text(timeString(elapsed))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()

                if let currentRound, let remaining = secondsRemainingInRound {
                    VStack(spacing: 5) {
                        Text(currentRound.name)
                            .font(.title2.bold())
                        Text("\(remaining) seconds")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                } else {
                    Text(template.subtitle)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 18) {
                    Button {
                        running.toggle()
                        configureTimer()
                    } label: {
                        Label(running ? "Pause" : "Resume",
                              systemImage: running ? "pause.fill" : "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)

                    Button {
                        running = false
                        timer?.invalidate()
                        showFinish = true
                    } label: {
                        Label("Finish", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .onAppear { configureTimer() }
            .onDisappear { timer?.invalidate() }
            .sheet(isPresented: $showFinish) {
                finishSheet
            }
        }
    }

    private var finishSheet: some View {
        NavigationStack {
            Form {
                Section("Completed") {
                    LabeledContent("Duration", value: timeString(elapsed))
                    TextField("Active calories (optional)", text: $activeCaloriesText)
                        .keyboardType(.decimalPad)

                    if template.kind == .running || template.kind == .cycling {
                        TextField("Distance in kilometres (optional)", text: $distanceText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("Notes") {
                    TextField("How did it feel?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Save workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Continue") {
                        showFinish = false
                        running = true
                        configureTimer()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWorkout() }
                }
            }
        }
    }

    private func configureTimer() {
        timer?.invalidate()
        guard running else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsed += 1
        }
    }

    private func saveWorkout() {
        let calories = number(activeCaloriesText)
        let distance = number(distanceText)

        let workout = WorkoutEntry(
            kind: template.kind,
            title: template.title,
            durationSeconds: Double(max(elapsed, 1)),
            activeCalories: calories,
            distanceKilometres: distance,
            notes: notes
        )
        context.insert(workout)

        Task {
            try? await health.saveWorkout(
                kind: template.kind,
                start: startedAt,
                end: Date(),
                activeCalories: calories,
                distanceKilometres: distance
            )
            await health.refreshToday()
        }

        showFinish = false
        dismiss()
    }

    private func number(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
