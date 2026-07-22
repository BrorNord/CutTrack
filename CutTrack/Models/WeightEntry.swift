import Foundation
import SwiftData

@Model
final class WeightEntry {
    var kilograms: Double
    var createdAt: Date

    init(kilograms: Double, createdAt: Date = .now) {
        self.kilograms = kilograms
        self.createdAt = createdAt
    }
}
