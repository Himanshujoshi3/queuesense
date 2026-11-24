import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var orderStore: OrderStore
    @State private var showingCart = false

    var body: some View {
        TabView {
            MenuListView(showingCart: $showingCart)
                .tabItem {
                    Label("Menu", systemImage: "menucard")
                }

            OrderTrackingView()
                .tabItem {
                    Label("Live Order", systemImage: "timer")
                }

            OrdersHistoryView()
                .tabItem {
                    Label("Orders", systemImage: "clock.arrow.circlepath")
                }
        }
        .sheet(isPresented: $showingCart) {
            CartView()
                .environmentObject(orderStore)
        }
    }
}

/// Checkout sheet: review the cart, see the predicted wait, place the order.
struct CartView: View {
    @EnvironmentObject private var orderStore: OrderStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if orderStore.cart.isEmpty {
                    ContentUnavailableView(
                        "Cart is empty",
                        systemImage: "basket",
                        description: Text("Add something from the menu first.")
                    )
                } else {
                    List {
                        Section("Your order") {
                            ForEach(orderStore.cart, id: \.menuItem.id) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.menuItem.name)
                                        Text("₹\(Int(item.menuItem.price)) each")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Stepper(
                                        "\(item.quantity)",
                                        onIncrement: { orderStore.addToCart(item.menuItem) },
                                        onDecrement: { orderStore.removeFromCart(item.menuItem) }
                                    )
                                    .labelsHidden()
                                }
                            }
                        }

                        Section("Pickup") {
                            HStack {
                                Label("Predicted wait", systemImage: "hourglass")
                                Spacer()
                                Text("~\(orderStore.predictedWaitForCart()) min")
                                    .fontWeight(.semibold)
                            }
                            Text("Pay at the counter on pickup. Your order appears on the Dynamic Island and Lock Screen while it is being prepared.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Section {
                            HStack {
                                Text("Total")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("₹\(Int(orderStore.cartTotal))")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Place Order") {
                        orderStore.placeOrder()
                        dismiss()
                    }
                    .disabled(orderStore.cart.isEmpty || orderStore.activeOrder != nil)
                }
            }
        }
    }
}
