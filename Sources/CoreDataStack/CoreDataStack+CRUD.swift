import CoreData

public extension CoreDataStack {
    
    func create<T: NSManagedObject>(_ object: T) -> Result<T, Error> {
        do {
            try context.save()
            return .success(object)
        } catch {
            print(error)
            return .failure(error)
        }
    }
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate? = nil, limit: Int? = nil) -> Result<[T], Error> {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            let result = try context.fetch(request)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> Result<T?, Error> {
        let request = NSFetchRequest<T>(entityName: String(describing: objectType))
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request)
            return .success(result.first)
        } catch {
            return .failure(error)
        }
    }
    
    func update<T: NSManagedObject>(_ object: T) -> Result<T, Error> {
        do {
            try context.save()
            return .success(object)
        } catch {
            print(error)
            return .failure(error)
        }
    }
    
    func batchUpdate<T: NSManagedObject>(_ objectType: T.Type, _ properties: [AnyHashable: Any], predicate: NSPredicate?) -> Result<[T], Error> {
        let request = NSBatchUpdateRequest(entityName: String(describing: objectType))
        request.propertiesToUpdate = properties
        request.predicate = predicate
        request.resultType = .updatedObjectIDsResultType
      
        do {
            
            let objectIDs = try context.execute(request) as! NSBatchUpdateResult
            let objects = objectIDs.result as! [NSManagedObjectID]
            
            objects.forEach({ objID in
                let managedObject = context.object(with: objID)
                context.refresh(managedObject, mergeChanges: false)
            })
            
            saveContext()
            
            return fetch(T.self, predicate: predicate, limit: nil)
            
        }catch {
            return .failure(error)
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
