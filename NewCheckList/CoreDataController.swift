import CoreData

public final class CoreDataController<T>: NSObject, NSFetchedResultsControllerDelegate where T: NSFetchRequestResult {
    let fetchResultController: NSFetchedResultsController<T>
    
    public init(entityName: String,
                keyForSort: String,
                predicate: NSPredicate? = nil) {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchResultController = NSFetchedResultsController<T>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.instance.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        fetchResultController.delegate = self
    }
    
    public func fetch() {
        do {
            try fetchResultController.performFetch()
        } catch {
            print(error)
        }
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                
            }
        case .delete:
            if let indexPath = indexPath {
                
            }
        case .update: break
            
        default: break
            
        }
    }
}



