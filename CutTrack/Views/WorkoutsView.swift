import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Query(sort: \WorkoutEntry.completedAt, order: .reverse) private var history: [WorkoutEntry]
    @State private var selectedKind: WorkoutKind = .kettlebell
    @State private var selectedTemplate: WorkoutTemplate?

    private var templates: [WorkoutTemplate] {
        WorkoutTemplate.library.filter { $0.kind == selectedKind }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("Workout", selection: $selectedKind) {
                        ForEach(WorkoutKind.allCases) { kind in
                            Label(kind.title, systemImage: kind.symbol).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Start a workout")
                            .font(.title2.bold())

                        ForEach(templates) { template in
                            Button {
                                selectedTemplate = template
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: template.kind.symbol)
                                        .font(.title2)
                                        .frame(width: 48, height: 48)
                                        .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                                        .foregroundStyle(.green)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(template.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text(template.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text("\(template.plannedMinutes)")
                                            .font(.title3.bold())
                                        Text("min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent workouts")
                            .font(.title2.bold())

                        if history.isEmpty {
                            ContentUnavailableView(
                                "No workouts yet",
                                systemImage: "figure.run",
                                description: Text("Completed workouts will appear here.")
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        } else {
                            ForEach(history.prefix(10)) { workout in
                                HStack {
                                    Image(systemName: workout.kind.symbol)
                                        .foregroundStyle(.green)
                                        .frame(width: 34)
                                    VStack(alignment: .leading) {
                                        Text(workout.title).fontWeight(.semibold)
                                        Text(workout.completedAt, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("\(Int(workout.durationSeconds / 60)) min")
                                        if workout.activeCalories > 0 {
                                            Text("\(Int(workout.activeCalories)) kcal")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Workouts")
            .sheet(item: $selectedTemplate) { template in
                ActiveWorkoutView(template: template)
            }
        }
    }
}
