import Foundation

/// A placed cafeteria order.
struct CafeteriaOrder: Identifiable, Codable, Hashable {
    let id: UUID
    let items: [OrderItem]
    let placedAt: Date
    var status: OrderStatus
    /// Predicted wait (minutes) at the moment the order was placed.
    let predictedWaitMinutes: Int

    var total: Double {
        items.reduce(0) { $0 + $1.menuItem.price * Double($1.quantity) }
    }

    var itemsSummary: String {
        items.map { "\($0.quantity)x \($0.menuItem.name)" }.joined(separator: ", ")
    }

    struct OrderItem: Codable, Hashable {
        let menuItem: MenuItem
        var quantity: Int
    }

    enum OrderStatus: String, CaseIterable, Codable {
        case placed = "Placed"
        case preparing = "Preparing"
        case ready = "Ready for Pickup"
        case completed = "Completed"

        /// Colour-free progress value for progress bars (0...1).
        var progress: Double {
            switch self {
            case .placed: return 0.25
            case .preparing: return 0.55
            case .ready: return 0.9
            case .completed: return 1.0
            }
        }

        var next: OrderStatus? {
            switch self {
            case .placed: return .preparing
            case .preparing: return .ready
            case .ready: return .completed
            case .completed: return nil
            }
        }
    }
}
