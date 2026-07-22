import Foundation
import ActivityKit

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published var running = false

    func start(food: Int, active: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = CutTrackActivityAttributes.ContentState(
            foodCalories: food,
            activeCalories: active,
            remainingFood: max(0, Int(Goals.foodCalories) - food)
        )
        do {
            _ = try Activity.request(
                attributes: CutTrackActivityAttributes(date: .now),
                content: ActivityContent(state: state, staleDate: nil)
            )
            running = true
        } catch {
            running = false
        }
    }

    func update(food: Int, active: Int) async {
        let state = CutTrackActivityAttributes.ContentState(
            foodCalories: food,
            activeCalories: active,
            remainingFood: max(0, Int(Goals.foodCalories) - food)
        )
        for activity in Activity<CutTrackActivityAttributes>.activities {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    func end() async {
        for activity in Activity<CutTrackActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        running = false
    }
}
