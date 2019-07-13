import CoreData

public final class CoreDataController<T>: NSObject, NSFetchedResultsControllerDelegate where T: NSFetchRequestResult {
    public typealias UpdateCallback = () -> Void
    public typealias ChangeCallback = (CoreDataChange) -> Void
    
    let fetchResultController: NSFetchedResultsController<T>
    public var beginUpdate: UpdateCallback?
    public var endUpdate: UpdateCallback?
    public var changeCallback: ChangeCallback?
    
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
        beginUpdate?()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        endUpdate?()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        let change = CoreDataChange(
            indexPath: indexPath,
            type: CoreDataChange.ChangeType(type: type),
            newIndexPath: newIndexPath
        )
        changeCallback?(change)
    }
}

public struct CoreDataChange {
    public enum ChangeType {
        case insert
        case delete
        case move
        case update
        
        fileprivate init (type: NSFetchedResultsChangeType) {
            switch type {
            case .insert:
                self = .insert
            case .delete:
                self = .delete
            case .move:
                self = .move
            case .update:
                self = .update
            @unknown default:
                fatalError()
            }
        }
    }
    
    let indexPath: IndexPath?
    let type: ChangeType
    let newIndexPath: IndexPath?
}
