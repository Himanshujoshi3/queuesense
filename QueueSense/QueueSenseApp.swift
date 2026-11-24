import SwiftUI

/// QueueSense — Smart Cafeteria Wait-Time & Live Order Tracker.
/// Native iOS app: browse the cafeteria menu, place an order, and track
/// it live (Dynamic Island / Lock Screen via ActivityKit, home-screen
/// widget via WidgetKit). Orders persist locally with Core Data.
@main
struct QueueSenseApp: App {
    @StateObject private var orderStore = OrderStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(orderStore)
        }
    }
}
