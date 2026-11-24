import SwiftUI

/// Browse the cafeteria menu, grouped by category, and add items to the cart.
struct MenuListView: View {
    @EnvironmentObject private var orderStore: OrderStore
    @Binding var showingCart: Bool
    @State private var selectedCategory: MenuItem.Category? = nil

    private var visibleItems: [MenuItem] {
        guard let selectedCategory else { return MenuItem.sampleMenu }
        return MenuItem.sampleMenu.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(nil as MenuItem.Category?)
                        ForEach(MenuItem.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category as MenuItem.Category?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }

                ForEach(visibleItems) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name)
                                    .fontWeight(.medium)
                                if item.isVeg {
                                    Text("VEG")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.15))
                                        .foregroundStyle(.green)
                                        .clipShape(Capsule())
                                }
                            }
                            Text(item.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("₹\(Int(item.price)) · ~\(item.prepMinutes) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        StepperControl(item: item)
                    }
                }
            }
            .navigationTitle("QueueSense")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCart = true
                    } label: {
                        Label(
                            "Cart (\(orderStore.cart.reduce(0) { $0 + $1.quantity }))",
                            systemImage: "basket"
                        )
                    }
                    .disabled(orderStore.cart.isEmpty)
                }
            }
        }
    }

    /// Small +/- control for one menu item.
    private struct StepperControl: View {
        @EnvironmentObject private var orderStore: OrderStore
        let item: MenuItem

        var body: some View {
            let quantity = orderStore.quantityInCart(item)
            if quantity == 0 {
                Button("Add") { orderStore.addToCart(item) }
                    .buttonStyle(.bordered)
            } else {
                HStack(spacing: 12) {
                    Button { orderStore.removeFromCart(item) } label: {
                        Image(systemName: "minus.circle.fill")
                    }
                    Text("\(quantity)")
                        .fontWeight(.semibold)
                    Button { orderStore.addToCart(item) } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
