import Foundation
import CoreData

open class CoreDataStack<T: NSPersistentContainer> {

    public typealias AvailableNotification = CachedValueTypedNotification<NSManagedObjectContext>

    /// Notification that will be emitted when the persistent container is available to use.
    public let availableNotification: AvailableNotification

    /// The context associated with all managed objects from the persistent container
    public var managedObjectContext: NSManagedObjectContext? { availableNotification.cachedValue }

    /// Container that holds the managed data items
    private let persistentContainer: T

    /// The managed object context that works safely with the main thread.
    public lazy var mainContext: NSManagedObjectContext = { persistentContainer.viewContext }()

    /**
     Construct a new Core Data stack that will provide values from a given persistent container

     - parameter container: the container to work with
     */
    public required init(container: T) {
        availableNotification = AvailableNotification(name: container.name + "ManagedObjectContext")
        persistentContainer = container
        createStack()
    }
}

extension CoreDataStack {

    /**
     Save any changes in main managed object context.
     */
    public func saveMainContext() { saveOneContext(mainContext) }
}

extension CoreDataStack {

    private func createStack() {
        persistentContainer.loadPersistentStores { [weak self] _, _ in
            guard let self = self else { return }
            let viewContext = self.persistentContainer.viewContext
            self.availableNotification.post(value: viewContext)
        }
    }

    private func saveOneContext(_ context: NSManagedObjectContext) {
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
