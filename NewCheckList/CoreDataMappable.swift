import CoreData

protocol CoreDataMappable {
    associatedtype CoreDataModel: NSFetchRequestResult
    
    init(model: CoreDataModel)
}
