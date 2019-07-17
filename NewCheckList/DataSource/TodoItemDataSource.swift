import UIKit

public final class TodoItemDataSource: NSObject {
    let coreDataController: CoreDataController<TodoItem, TodoItemViewModel>
    let tableView: UITableView
    
    init(tableView: UITableView) {
        coreDataController = CoreDataController<TodoItem, TodoItemViewModel>(entityName: "TodoItem", keyForSort: "name")
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        coreDataController.beginUpdate = { [weak self] in
            self?.tableView.beginUpdates()
        }
        coreDataController.endUpdate = { [weak self] in
            self?.tableView.endUpdates()
        }
        coreDataController.changeCallback = { [weak self] change in
            switch change.type {
            case let .delete(indexPath):
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            case let .insert(indexPath):
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
            case let  .move(fromIndexPath, toIndexPath):
                self?.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
            case let .update(indexPath):
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case let .error(error):
                print(error)
            }
        }
    }
    
    func fetch() {
        coreDataController.fetch()
    }
    
    func addTodoItem(name: String) {
        let item = TodoItem()
        item.text = name
        coreDataController.add(model: item)
    }
    
    func deleteTodoItems(at indexPaths: [IndexPath]) {
        coreDataController.deleteItems(at: indexPaths)
    }
    
    func editItemName(indexPath: IndexPath, name: String) {
        coreDataController.updateModel(indexPath: indexPath) { (todoItem) in
            todoItem.text = name
        }
    }
}

extension TodoItemDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataController.numberOfItems(in: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = coreDataController.getItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell", for: indexPath) as! TodoItemTableViewCell
        cell.configure(with: vm)
        cell.editItemCallback = { [weak self] text in
            self?.editItemName(indexPath: indexPath, name: text ?? "")
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteTodoItems(at: [indexPath])
    }
    
    //TODO: add moveRowAt func
}
