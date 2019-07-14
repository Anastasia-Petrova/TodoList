
import UIKit

public final class TodoItemDataSource: NSObject {
    let coreDataController: CoreDataController<TodoItem, TodoItemViewModel>
    
    override init() {
        coreDataController = CoreDataController<TodoItem, TodoItemViewModel>(entityName: "TodoItem", keyForSort: "name")
        super.init()
    }
}

extension TodoItemDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
