import Foundation
import ActivityKit

struct CutTrackActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var foodCalories: Int
        var activeCalories: Int
        var remainingFood: Int
    }

    var date: Date
}
