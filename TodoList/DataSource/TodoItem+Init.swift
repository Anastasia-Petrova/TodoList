import CoreData

extension TodoItem {
    convenience init() {
        self.init(entity: TodoItem.entity(),
                  insertInto: nil)
    }
}
