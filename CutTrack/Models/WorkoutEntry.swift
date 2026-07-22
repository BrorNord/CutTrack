import Foundation
import SwiftData

enum WorkoutKind: String, Codable, CaseIterable, Identifiable {
    case kettlebell
    case running
    case cycling

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kettlebell: return "Kettlebell"
        case .running: return "Running"
        case .cycling: return "Cycling"
        }
    }

    var symbol: String {
        switch self {
        case .kettlebell: return "dumbbell.fill"
        case .running: return "figure.run"
        case .cycling: return "bicycle"
        }
    }
}

@Model
final class WorkoutEntry {
    var kindRaw: String
    var title: String
    var durationSeconds: Double
    var activeCalories: Double
    var distanceKilometres: Double
    var notes: String
    var completedAt: Date

    var kind: WorkoutKind {
        get { WorkoutKind(rawValue: kindRaw) ?? .kettlebell }
        set { kindRaw = newValue.rawValue }
    }

    init(
        kind: WorkoutKind,
        title: String,
        durationSeconds: Double,
        activeCalories: Double = 0,
        distanceKilometres: Double = 0,
        notes: String = "",
        completedAt: Date = .now
    ) {
        self.kindRaw = kind.rawValue
        self.title = title
        self.durationSeconds = durationSeconds
        self.activeCalories = activeCalories
        self.distanceKilometres = distanceKilometres
        self.notes = notes
        self.completedAt = completedAt
    }
}
