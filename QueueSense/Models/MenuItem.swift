import Foundation

/// One dish on the cafeteria menu.
struct MenuItem: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let category: Category
    let price: Double
    let prepMinutes: Int
    let isVeg: Bool
    let description: String

    enum Category: String, CaseIterable, Codable {
        case southIndian = "South Indian"
        case northIndian = "North Indian"
        case snacks = "Snacks"
        case beverages = "Beverages"
    }

    init(
        id: UUID = UUID(),
        name: String,
        category: Category,
        price: Double,
        prepMinutes: Int,
        isVeg: Bool,
        description: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.price = price
        self.prepMinutes = prepMinutes
        self.isVeg = isVeg
        self.description = description
    }

    /// Sample menu used until a real cafeteria backend is plugged in.
    /// Prices are in INR, as served in a campus cafeteria.
    static let sampleMenu: [MenuItem] = [
        MenuItem(name: "Masala Dosa", category: .southIndian, price: 60, prepMinutes: 8, isVeg: true,
                 description: "Crisp dosa with spiced potato filling, sambar and chutney."),
        MenuItem(name: "Idli Sambar (2 pc)", category: .southIndian, price: 40, prepMinutes: 5, isVeg: true,
                 description: "Steamed idlis served with hot sambar."),
        MenuItem(name: "Veg Thali", category: .northIndian, price: 120, prepMinutes: 12, isVeg: true,
                 description: "Dal, seasonal sabzi, rice, 3 rotis, salad and curd."),
        MenuItem(name: "Paneer Butter Masala + 2 Roti", category: .northIndian, price: 110, prepMinutes: 12, isVeg: true,
                 description: "Creamy paneer curry with butter rotis."),
        MenuItem(name: "Chicken Biryani", category: .northIndian, price: 150, prepMinutes: 15, isVeg: false,
                 description: "Fragrant basmati biryani with raita and salan."),
        MenuItem(name: "Veg Sandwich", category: .snacks, price: 50, prepMinutes: 6, isVeg: true,
                 description: "Grilled triple-layer sandwich with mint chutney."),
        MenuItem(name: "Samosa (2 pc)", category: .snacks, price: 30, prepMinutes: 4, isVeg: true,
                 description: "Crisp samosas with tamarind chutney."),
        MenuItem(name: "Masala Chai", category: .beverages, price: 20, prepMinutes: 3, isVeg: true,
                 description: "Slow-brewed chai with ginger and cardamom."),
        MenuItem(name: "Cold Coffee", category: .beverages, price: 60, prepMinutes: 4, isVeg: true,
                 description: "Chilled coffee blended with milk and ice cream."),
    ]
}
