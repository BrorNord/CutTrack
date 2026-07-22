import Foundation
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingDescription: String
    var barcode: String?
    var createdAt: Date

    init(
        name: String,
        calories: Double,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        servingDescription: String = "1 serving",
        barcode: String? = nil,
        createdAt: Date = .now
    ) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingDescription = servingDescription
        self.barcode = barcode
        self.createdAt = createdAt
    }
}
