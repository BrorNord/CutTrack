import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var preset: ScannedFood?

    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var grams = "100"

    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Name", text: $name)
                    TextField("Amount in grams", text: $grams).keyboardType(.decimalPad)
                }
                Section("Nutrition for this amount") {
                    TextField("Calories", text: $calories).keyboardType(.decimalPad)
                    TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
                    TextField("Carbohydrates (g)", text: $carbs).keyboardType(.decimalPad)
                    TextField("Fat (g)", text: $fat).keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || Double(calories.replacingOccurrences(of: ",", with: ".")) == nil)
                }
            }
            .onAppear { applyPreset() }
        }
    }

    private func applyPreset() {
        guard let preset else { return }
        name = preset.name
        calories = String(format: "%.0f", preset.caloriesPer100g)
        protein = String(format: "%.1f", preset.proteinPer100g)
        carbs = String(format: "%.1f", preset.carbsPer100g)
        fat = String(format: "%.1f", preset.fatPer100g)
    }

    private func number(_ value: String) -> Double {
        Double(value.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private func save() {
        context.insert(FoodEntry(
            name: name,
            calories: number(calories),
            protein: number(protein),
            carbs: number(carbs),
            fat: number(fat),
            servingDescription: "\(grams) g",
            barcode: preset?.barcode
        ))
        dismiss()
    }
}
