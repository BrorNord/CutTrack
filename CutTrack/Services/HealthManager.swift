import Foundation
import HealthKit

@MainActor
final class HealthManager: ObservableObject {
    private let store = HKHealthStore()

    @Published var activeCalories: Double = 0
    @Published var runningMinutes: Double = 0
    @Published var latestWeight: Double?
    @Published var isAuthorized = false
    @Published var errorMessage: String?

    private let activeType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "Apple Health is unavailable on this device."
            return
        }

        let read: Set<HKObjectType> = [activeType, weightType, HKObjectType.workoutType()]
        let write: Set<HKSampleType> = [weightType, HKObjectType.workoutType(), activeType]

        do {
            try await store.requestAuthorization(toShare: write, read: read)
            isAuthorized = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshToday() async {
        async let calories = loadActiveCalories()
        async let run = loadRunningMinutes()
        async let weight = loadLatestWeight()

        activeCalories = await calories
        runningMinutes = await run
        latestWeight = await weight
        SharedSnapshot.save(active: Int(activeCalories))
    }

    private var todayPredicate: NSPredicate {
        let start = Calendar.current.startOfDay(for: .now)
        return HKQuery.predicateForSamples(withStart: start, end: .now)
    }

    private func loadActiveCalories() async -> Double {
        await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: activeType,
                quantitySamplePredicate: todayPredicate,
                options: .cumulativeSum
            ) { _, result, _ in
                continuation.resume(
                    returning: result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                )
            }
            store.execute(query)
        }
    }

    private func loadRunningMinutes() async -> Double {
        await withCheckedContinuation { continuation in
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                todayPredicate, workoutPredicate
            ])
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let seconds = (samples as? [HKWorkout])?.reduce(0) { $0 + $1.duration } ?? 0
                continuation.resume(returning: seconds / 60)
            }
            store.execute(query)
        }
    }

    private func loadLatestWeight() async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: weightType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?
                    .quantity.doubleValue(for: .gramUnit(with: .kilo))
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }


    func saveWorkout(
        kind: WorkoutKind,
        start: Date,
        end: Date,
        activeCalories: Double,
        distanceKilometres: Double
    ) async throws {
        let activityType: HKWorkoutActivityType
        switch kind {
        case .kettlebell:
            activityType = .traditionalStrengthTraining
        case .running:
            activityType = .running
        case .cycling:
            activityType = .cycling
        }

        var samples: [HKSample] = []

        if activeCalories > 0 {
            samples.append(
                HKQuantitySample(
                    type: activeType,
                    quantity: HKQuantity(unit: .kilocalorie(), doubleValue: activeCalories),
                    start: start,
                    end: end
                )
            )
        }

        if distanceKilometres > 0, kind == .running || kind == .cycling {
            let identifier: HKQuantityTypeIdentifier =
                kind == .running ? .distanceWalkingRunning : .distanceCycling

            if let distanceType = HKQuantityType.quantityType(forIdentifier: identifier) {
                samples.append(
                    HKQuantitySample(
                        type: distanceType,
                        quantity: HKQuantity(unit: .meterUnit(with: .kilo), doubleValue: distanceKilometres),
                        start: start,
                        end: end
                    )
                )
            }
        }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = kind == .kettlebell ? .indoor : .unknown

        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: configuration,
            device: .local()
        )

        try await builder.beginCollection(at: start)
        if !samples.isEmpty {
            try await builder.addSamples(samples)
        }
        try await builder.endCollection(at: end)
        _ = try await builder.finishWorkout()
    }

    func saveWeight(_ kilograms: Double) async throws {
        let sample = HKQuantitySample(
            type: weightType,
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: kilograms),
            start: .now,
            end: .now
        )
        try await store.save(sample)
        latestWeight = kilograms
    }
}
