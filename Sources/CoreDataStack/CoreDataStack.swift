import CoreData
import CloudKit

public class CoreDataStack {
            
    public var container: NSPersistentCloudKitContainer
    
    public var context: NSManagedObjectContext {
        return container.viewContext
    }

    public init(model: NSManagedObjectModel, inMemory: Bool = false) {
        #if os(watchOS)
        container = Self.setupCloudKitContainer(model: model, withSync: true, inMemory: inMemory)
        #else
        let cloudSync = NSUbiquitousKeyValueStore.default.bool(forKey: "iCloudSyncKey")
        container = Self.setupCloudKitContainer(model: model, withSync: cloudSync, inMemory: inMemory)
        #endif
    }
    
    public static func setupContainer(model: NSManagedObjectModel, withSync iCloudSync: Bool) -> NSPersistentCloudKitContainer {
        return Self.setupCloudKitContainer(model: model, withSync: iCloudSync)
    }
    
    internal static func setupCloudKitContainer(model: NSManagedObjectModel, withSync: Bool, inMemory: Bool = false) -> NSPersistentCloudKitContainer {
        let container = NSPersistentCloudKitContainer(name: "TopSpinSPM", managedObjectModel: model)
       
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        print("cloudkit container identifier : \(description.cloudKitContainerOptions?.containerIdentifier ?? "")")

        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        if !withSync {
            description.cloudKitContainerOptions = nil
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }
}
