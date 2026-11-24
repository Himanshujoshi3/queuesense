import ActivityKit
import Foundation

/// Starts, updates and ends the Live Activity for the active order.
/// No-ops on devices / iOS versions where Live Activities are unavailable.
@MainActor
final class LiveActivityManager {
    private var activity: Activity<WaitTimeAttributes>?

    func start(for order: CafeteriaOrder) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = WaitTimeAttributes(
            orderId: order.id,
            itemsSummary: order.itemsSummary
        )
        let state = WaitTimeAttributes.ContentState(
            status: order.status.rawValue,
            waitMinutesRemaining: order.predictedWaitMinutes,
            progress: order.status.progress
        )
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: state
            )
        } catch {
            print("QueueSense: Live Activity failed to start: \(error)")
        }
    }

    func update(for order: CafeteriaOrder, waitMinutesRemaining: Int) async {
        guard let activity else { return }
        let state = WaitTimeAttributes.ContentState(
            status: order.status.rawValue,
            waitMinutesRemaining: waitMinutesRemaining,
            progress: order.status.progress
        )
        await activity.update(ActivityContent(state: state, staleDate: nil))
    }

    func end(for order: CafeteriaOrder) async {
        guard let activity else { return }
        let state = WaitTimeAttributes.ContentState(
            status: order.status.rawValue,
            waitMinutesRemaining: 0,
            progress: 1.0
        )
        await activity.end(
            ActivityContent(state: state, staleDate: nil),
            dismissalPolicy: .immediate
        )
        self.activity = nil
    }
}
