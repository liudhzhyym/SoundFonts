// Copyright © 2020 Brad Howes. All rights reserved.

import CoreData

/**
 Customized NSPersistentContainer that knows how to locate and load the managed object model (MOM) resource. It then
 caches this value for future use -- basically useful for unit tests.
 */
open class PersistentContainer: NSPersistentContainer {

    /// Place the DB into the shared documents directory so both the app and the AUV3 extention can see it.
    override open class func defaultDirectoryURL() -> URL {
        FileManager.default.sharedDocumentsDirectory
    }

    public init(modelName: String) {
        let bundle = Bundle(for: PersistentContainer.self)
        let momUrl = bundle.url(forResource: modelName, withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: momUrl)!
        super.init(name: modelName, managedObjectModel: mom)
    }
}

public extension PersistentContainer {

    typealias LoadStoreError = (NSPersistentStoreDescription, Error)

    func destroyPersistentStores() throws {
        try persistentStoreCoordinator.destroyPersistentStores(persistentStoreDescriptions)
    }

    func removeStores() throws {
        try persistentStoreCoordinator.removeStores()
    }
}

extension NSPersistentStoreCoordinator {

    func destroyPersistentStores(_ descriptions: [NSPersistentStoreDescription]) throws {
        try descriptions.forEach { desc in
            try desc.url.map {try destroyPersistentStore(at: $0, ofType: desc.type)}
        }
    }

    func removeStores() throws {
        try persistentStores.forEach { try remove($0) }
    }
}
