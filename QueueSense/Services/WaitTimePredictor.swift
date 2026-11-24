import CoreML
import Foundation

/// Predicts how long a new order will take, in minutes.
///
/// Two layers:
/// 1. On-device Core ML model — `WaitTimePredictor.mlmodel`, trained with
///    Create ML from `WaitTimeTrainer/training_data.csv` (see
///    `WaitTimeTrainer/TrainWaitTime.swift`). If the compiled model is in
///    the app bundle it is used; the model file is generated on a Mac and
///    is not checked into this repo.
/// 2. Heuristic fallback — a small linear model whose weights come from
///    the same sample data, so predictions still work with no .mlmodel.
///
/// Inputs: hour of day, active orders ahead in the queue, items in the
/// new order, and the longest prep time among its items.
enum WaitTimePredictor {
    /// Fallback weights, fitted on the sample training data.
    /// wait ≈ 4 + 1.1 * activeOrders + 0.9 * itemCount + 0.6 * longestPrep
    private static let baseMinutes = 4.0
    private static let perActiveOrder = 1.1
    private static let perItem = 0.9
    private static let perLongestPrepMinute = 0.6

    static func predict(
        hour: Int,
        activeOrders: Int,
        items: [CafeteriaOrder.OrderItem]
    ) -> Int {
        if let mlPrediction = predictWithCoreML(
            hour: hour,
            activeOrders: activeOrders,
            items: items
        ) {
            return clamp(mlPrediction)
        }
        let longestPrep = items.map { $0.menuItem.prepMinutes }.max() ?? 0
        let itemCount = items.reduce(0) { $0 + $1.quantity }
        let estimate = baseMinutes
            + perActiveOrder * Double(activeOrders)
            + perItem * Double(itemCount)
            + perLongestPrepMinute * Double(longestPrep)
        return clamp(Int(estimate.rounded()))
    }

    /// Tries the bundled Core ML model; returns nil when there is no
    /// model file yet (or prediction fails), so the caller falls back.
    private static func predictWithCoreML(
        hour: Int,
        activeOrders: Int,
        items: [CafeteriaOrder.OrderItem]
    ) -> Int? {
        guard let url = Bundle.main.url(forResource: "WaitTimePredictor", withExtension: "mlmodelc") else {
            return nil
        }
        guard let model = try? MLModel(contentsOf: url) else { return nil }
        let itemCount = items.reduce(0) { $0 + $1.quantity }
        let longestPrep = items.map { $0.menuItem.prepMinutes }.max() ?? 0
        let inputs: [String: MLFeatureValue] = [
            "hour": MLFeatureValue(double: Double(hour)),
            "activeOrders": MLFeatureValue(double: Double(activeOrders)),
            "itemCount": MLFeatureValue(double: Double(itemCount)),
            "longestPrepMinutes": MLFeatureValue(double: Double(longestPrep)),
        ]
        guard let provider = try? MLDictionaryFeatureProvider(dictionary: inputs),
              let output = try? model.prediction(from: provider),
              let wait = output.featureValue(for: "waitMinutes")?.doubleValue
        else { return nil }
        return Int(wait.rounded())
    }

    private static func clamp(_ minutes: Int) -> Int {
        min(max(minutes, 5), 45)
    }
}
