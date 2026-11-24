import CoreData
import Foundation

/// Core Data stack for QueueSense.
///
/// The model is built in code (no .xcdatamodeld file) so the whole stack
/// is visible in one place. One entity, `StoredOrder`, keeps a local
/// history of placed orders: id, a human-readable summary of the items,
/// total, status and creation date.
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "QueueSense",
            managedObjectModel: Self.makeModel()
        )
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In a shipped app this would be reported, not fatalError'd.
                // Kept fatal here so a broken store is loud during development.
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("QueueSense: failed to save Core Data context: \(error)")
        }
    }

    // MARK: - Programmatic model

    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let order = NSEntityDescription()
        order.name = "StoredOrder"
        order.managedObjectClassName = NSStringFromClass(StoredOrder.self)

        func attribute(_ name: String, _ type: NSAttributeDescription.AttributeType) -> NSAttributeDescription {
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = true
            return attr
        }

        order.properties = [
            attribute("id", .UUIDAttributeType),
            attribute("itemsSummary", .stringAttributeType),
            attribute("total", .doubleAttributeType),
            attribute("status", .stringAttributeType),
            attribute("createdAt", .dateAttributeType),
        ]

        model.entities = [order]
        return model
    }
}

/// A placed order, persisted locally so order history survives restarts.
@objc(StoredOrder)
final class StoredOrder: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var itemsSummary: String?
    @NSManaged var total: Double
    @NSManaged var status: String?
    @NSManaged var createdAt: Date?

    @nonobjc static func fetchRequest() -> NSFetchRequest<StoredOrder> {
        NSFetchRequest<StoredOrder>(entityName: "StoredOrder")
    }
}
