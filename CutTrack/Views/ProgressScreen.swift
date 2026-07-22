import SwiftUI
import SwiftData
import Charts

struct ProgressScreen: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject private var health: HealthManager
    @Query(sort: \WeightEntry.createdAt) private var weights: [WeightEntry]
    @State private var weightText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weight trend").font(.title2.bold())
                        if weights.isEmpty {
                            ContentUnavailableView("No weight entries", systemImage: "scalemass")
                                .frame(height: 220)
                        } else {
                            Chart(weights) { item in
                                LineMark(x: .value("Date", item.createdAt), y: .value("kg", item.kilograms))
                                PointMark(x: .value("Date", item.createdAt), y: .value("kg", item.kilograms))
                            }
                            .frame(height: 230)
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add weight").font(.headline)
                        HStack {
                            TextField("106.0", text: $weightText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            Text("kg").foregroundStyle(.secondary)
                            Button("Save") { saveWeight() }
                                .buttonStyle(.borderedProminent).tint(.green)
                        }
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Consistency streak", systemImage: "flame.fill")
                            .font(.headline).foregroundStyle(.orange)
                        Text("\(Set(weights.map { Calendar.current.startOfDay(for: $0.createdAt) }).count) tracked days")
                            .font(.largeTitle.bold())
                        Text("Weekly trends matter more than daily water-weight changes.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }

    private func saveWeight() {
        let normalized = weightText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 40, value < 300 else { return }
        context.insert(WeightEntry(kilograms: value))
        Task { try? await health.saveWeight(value) }
        weightText = ""
    }
}
