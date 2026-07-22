import SwiftUI
import SwiftData

struct FoodLogView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \FoodEntry.createdAt, order: .reverse) private var entries: [FoodEntry]
    @State private var showAdd = false
    @State private var showScanner = false

    private var today: [FoodEntry] {
        entries.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Int(today.reduce(0) { $0 + $1.calories })) kcal").font(.title2.bold())
                            Text("of 1,894").foregroundStyle(.secondary)
                        }
                        Spacer()
                        Gauge(value: today.reduce(0) { $0 + $1.calories }, in: 0...Goals.foodCalories) { EmptyView() }
                            .gaugeStyle(.accessoryCircularCapacity).tint(.green)
                    }
                }

                Section("Today’s food") {
                    if today.isEmpty {
                        ContentUnavailableView("No food logged", systemImage: "fork.knife")
                    }
                    ForEach(today) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name).fontWeight(.semibold)
                                Spacer()
                                Text("\(Int(item.calories)) kcal").foregroundStyle(.green)
                            }
                            Text("\(Int(item.protein)) g protein • \(item.servingDescription)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets { context.delete(today[index]) }
                    }
                }
            }
            .navigationTitle("Food")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { showScanner = true } label: { Image(systemName: "barcode.viewfinder") }
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddFoodView() }
            .sheet(isPresented: $showScanner) { BarcodeScannerFlow() }
        }
    }
}
