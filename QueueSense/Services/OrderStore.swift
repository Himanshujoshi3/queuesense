import Combine
import CoreData
import Foundation

/// Owns the cart, the active order and order history.
///
/// Order-status progression here is a local demo simulation: a timer
/// advances the active order through Placed → Preparing → Ready →
/// Completed. In a real deployment the cafeteria backend would push
/// status updates instead; the Live Activity, widget and persistence
/// code paths are the same either way.
@MainActor
final class OrderStore: ObservableObject {
    @Published private(set) var cart: [CafeteriaOrder.OrderItem] = []
    @Published private(set) var activeOrder: CafeteriaOrder?
    @Published private(set) var pastOrders: [StoredOrder] = []

    private let liveActivity = LiveActivityManager()
    private var progressTimer: Timer?

    var cartTotal: Double {
        cart.reduce(0) { $0 + $1.menuItem.price * Double($1.quantity) }
    }

    var activeOrderCount: Int {
        activeOrder == nil ? 0 : 1
    }

    init() {
        loadHistory()
    }

    // MARK: - Cart

    func addToCart(_ item: MenuItem) {
        if let index = cart.firstIndex(where: { $0.menuItem.id == item.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(CafeteriaOrder.OrderItem(menuItem: item, quantity: 1))
        }
    }

    func removeFromCart(_ item: MenuItem) {
        guard let index = cart.firstIndex(where: { $0.menuItem.id == item.id }) else { return }
        if cart[index].quantity > 1 {
            cart[index].quantity -= 1
        } else {
            cart.remove(at: index)
        }
    }

    func quantityInCart(_ item: MenuItem) -> Int {
        cart.first(where: { $0.menuItem.id == item.id })?.quantity ?? 0
    }

    // MARK: - Ordering

    /// Predicted wait for the current cart, before placing the order.
    func predictedWaitForCart() -> Int {
        let hour = Calendar.current.component(.hour, from: Date())
        return WaitTimePredictor.predict(
            hour: hour,
            activeOrders: activeOrderCount,
            items: cart
        )
    }

    func placeOrder() {
        guard !cart.isEmpty, activeOrder == nil else { return }
        let order = CafeteriaOrder(
            id: UUID(),
            items: cart,
            placedAt: Date(),
            status: .placed,
            predictedWaitMinutes: predictedWaitForCart()
        )
        cart = []
        activeOrder = order
        persist(order: order)
        SharedQueueStatus.write(order: order)
        liveActivity.start(for: order)
        startProgressSimulation(for: order)
    }

    /// Advances the active order one step; called by the demo timer and
    /// by the "mark next step" control in the tracking view.
    func advanceActiveOrder() {
        guard var order = activeOrder, let next = order.status.next else { return }
        order.status = next
        activeOrder = order
        SharedQueueStatus.write(order: order)
        persistStatus(order: order)
        Task {
            let remaining = max(order.predictedWaitMinutes - 5, 0)
            await liveActivity.update(for: order, waitMinutesRemaining: remaining)
            if next == .completed {
                await liveActivity.end(for: order)
                SharedQueueStatus.clear()
                stopProgressSimulation()
            }
        }
    }

    // MARK: - Demo progression

    private func startProgressSimulation(for order: CafeteriaOrder) {
        stopProgressSimulation()
        // Demo pace: one step every 20 seconds so the full flow can be
        // watched in about a minute. Real wait times are shown in the UI.
        progressTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceActiveOrder()
            }
        }
    }

    private func stopProgressSimulation() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    // MARK: - Persistence (Core Data)

    private func persist(order: CafeteriaOrder) {
        let context = PersistenceController.shared.container.viewContext
        let stored = StoredOrder(context: context)
        stored.id = order.id
        stored.itemsSummary = order.itemsSummary
        stored.total = order.total
        stored.status = order.status.rawValue
        stored.createdAt = order.placedAt
        PersistenceController.shared.save()
        loadHistory()
    }

    private func persistStatus(order: CafeteriaOrder) {
        let context = PersistenceController.shared.container.viewContext
        let request = StoredOrder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", order.id as CVarArg)
        if let stored = try? context.fetch(request).first {
            stored.status = order.status.rawValue
            PersistenceController.shared.save()
        }
        loadHistory()
    }

    func loadHistory() {
        let context = PersistenceController.shared.container.viewContext
        let request = StoredOrder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        pastOrders = (try? context.fetch(request)) ?? []
    }
}
