import Foundation

/// App Group shared by the app and the QueueSenseWidget extension.
/// The widget reads the latest queue snapshot from these defaults.
enum SharedQueueStatus {
    static let suiteName = "group.com.himanshujoshi.queuesense"
    static let activeOrderKey = "activeOrderSummary"
    static let waitMinutesKey = "activeOrderWaitMinutes"
    static let statusKey = "activeOrderStatus"
    static let updatedAtKey = "activeOrderUpdatedAt"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    static func write(order: CafeteriaOrder) {
        guard let defaults = defaults else { return }
        defaults.set(order.itemsSummary, forKey: activeOrderKey)
        defaults.set(order.predictedWaitMinutes, forKey: waitMinutesKey)
        defaults.set(order.status.rawValue, forKey: statusKey)
        defaults.set(Date(), forKey: updatedAtKey)
    }

    static func clear() {
        guard let defaults = defaults else { return }
        defaults.removeObject(forKey: activeOrderKey)
        defaults.removeObject(forKey: waitMinutesKey)
        defaults.removeObject(forKey: statusKey)
        defaults.removeObject(forKey: updatedAtKey)
    }

    struct Snapshot {
        let itemsSummary: String
        let waitMinutes: Int
        let status: String
    }

    static func read() -> Snapshot? {
        guard let defaults = defaults,
              let summary = defaults.string(forKey: activeOrderKey) else { return nil }
        return Snapshot(
            itemsSummary: summary,
            waitMinutes: defaults.integer(forKey: waitMinutesKey),
            status: defaults.string(forKey: statusKey) ?? ""
        )
    }
}
