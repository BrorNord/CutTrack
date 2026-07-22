import Foundation

struct WorkoutTemplate: Identifiable, Hashable {
    let id = UUID()
    let kind: WorkoutKind
    let title: String
    let subtitle: String
    let plannedMinutes: Int
    let rounds: [WorkoutRound]

    static let library: [WorkoutTemplate] = [
        WorkoutTemplate(
            kind: .kettlebell,
            title: "Kettlebell Full Body",
            subtitle: "Swings, goblet squats, rows and presses",
            plannedMinutes: 25,
            rounds: [
                .init(name: "Warm-up", seconds: 180),
                .init(name: "Kettlebell swings", seconds: 45),
                .init(name: "Rest", seconds: 20),
                .init(name: "Goblet squats", seconds: 45),
                .init(name: "Rest", seconds: 20),
                .init(name: "One-arm rows", seconds: 45),
                .init(name: "Rest", seconds: 20),
                .init(name: "Clean and press", seconds: 45),
                .init(name: "Rest", seconds: 60)
            ]
        ),
        WorkoutTemplate(
            kind: .kettlebell,
            title: "10-Minute Swing Session",
            subtitle: "Simple conditioning session",
            plannedMinutes: 10,
            rounds: [
                .init(name: "Swings", seconds: 30),
                .init(name: "Rest", seconds: 30)
            ]
        ),
        WorkoutTemplate(
            kind: .running,
            title: "Easy Run",
            subtitle: "Comfortable conversational pace",
            plannedMinutes: 30,
            rounds: []
        ),
        WorkoutTemplate(
            kind: .running,
            title: "Run/Walk Intervals",
            subtitle: "2 minutes running, 1 minute walking",
            plannedMinutes: 30,
            rounds: [
                .init(name: "Run", seconds: 120),
                .init(name: "Walk", seconds: 60)
            ]
        ),
        WorkoutTemplate(
            kind: .cycling,
            title: "Easy Ride",
            subtitle: "Steady aerobic cycling",
            plannedMinutes: 45,
            rounds: []
        ),
        WorkoutTemplate(
            kind: .cycling,
            title: "Cycling Intervals",
            subtitle: "3 minutes hard, 2 minutes easy",
            plannedMinutes: 35,
            rounds: [
                .init(name: "Hard", seconds: 180),
                .init(name: "Easy", seconds: 120)
            ]
        )
    ]
}

struct WorkoutRound: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let seconds: Int
}
