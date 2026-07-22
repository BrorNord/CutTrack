import Foundation
import WidgetKit

enum SharedSnapshot {
    private static let defaults = UserDefaults(suiteName: "group.dk.blbit.cuttrack")

    static func save(food: Int? = nil, active: Int? = nil) {
        if let food { defaults?.set(food, forKey: "food") }
        if let active { defaults?.set(active, forKey: "active") }
        defaults?.set(Date(), forKey: "updated")
        WidgetCenter.shared.reloadAllTimelines()
    }

    static var food: Int { defaults?.integer(forKey: "food") ?? 0 }
    static var active: Int { defaults?.integer(forKey: "active") ?? 0 }
}
