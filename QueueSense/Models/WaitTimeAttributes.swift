import ActivityKit
import Foundation

/// Live Activity attributes for an in-progress order.
/// Shown on the Dynamic Island and Lock Screen while the order is live.
struct WaitTimeAttributes: ActivityAttributes {
    /// Fixed data for the activity: which order and what was ordered.
    var orderId: UUID
    var itemsSummary: String

    /// Changing data, updated as the order progresses.
    struct ContentState: Codable, Hashable {
        var status: String
        var waitMinutesRemaining: Int
        var progress: Double
    }
}
