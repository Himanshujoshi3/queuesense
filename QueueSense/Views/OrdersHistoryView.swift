import SwiftUI

/// Order history, read back from Core Data (local persistence).
struct OrdersHistoryView: View {
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        NavigationStack {
            Group {
                if orderStore.pastOrders.isEmpty {
                    ContentUnavailableView(
                        "No orders yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Orders you place are saved on this device.")
                    )
                } else {
                    List(orderStore.pastOrders, id: \.id) { stored in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stored.itemsSummary ?? "Order")
                                .fontWeight(.medium)
                            HStack {
                                Text(stored.status ?? "")
                                Spacer()
                                Text("₹\(Int(stored.total))")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            if let date = stored.createdAt {
                                Text(date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Orders")
            .refreshable {
                orderStore.loadHistory()
            }
        }
    }
}
