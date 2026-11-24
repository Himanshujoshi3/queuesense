import SwiftUI

/// Live view of the active order: status, predicted wait, progress,
/// and a demo control to advance the order to its next step.
struct OrderTrackingView: View {
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        NavigationStack {
            Group {
                if let order = orderStore.activeOrder {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(order.status.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("~\(order.predictedWaitMinutes) min wait at order time")
                                    .foregroundStyle(.secondary)
                            }

                            ProgressView(value: order.status.progress)
                                .tint(.green)

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(CafeteriaOrder.OrderStatus.allCases, id: \.self) { step in
                                    HStack {
                                        Image(systemName: step.progress <= order.status.progress
                                              ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(step.progress <= order.status.progress ? .green : .secondary)
                                        Text(step.rawValue)
                                    }
                                }
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Items")
                                    .font(.headline)
                                ForEach(order.items, id: \.menuItem.id) { item in
                                    HStack {
                                        Text("\(item.quantity)x \(item.menuItem.name)")
                                        Spacer()
                                        Text("₹\(Int(item.menuItem.price * Double(item.quantity)))")
                                    }
                                }
                                HStack {
                                    Text("Total").fontWeight(.semibold)
                                    Spacer()
                                    Text("₹\(Int(order.total))").fontWeight(.bold)
                                }
                            }

                            Text("Live on your Dynamic Island and Lock Screen, and in the QueueSense widget.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if order.status.next != nil {
                                Button("Advance to \(order.status.next!.rawValue) (demo)") {
                                    orderStore.advanceActiveOrder()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "No live order",
                        systemImage: "timer",
                        description: Text("Place an order from the Menu tab and track it here.")
                    )
                }
            }
            .navigationTitle("Live Order")
        }
    }
}
