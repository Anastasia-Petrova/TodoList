import UIKit
import EasyCoreData

public final class TodoItemDataSource: NSObject {
    let coreDataController: CoreDataController<TodoItem, TodoItemViewModel>
    let tableView: UITableView
    
    init(tableView: UITableView) {
        coreDataController = CoreDataController<TodoItem, TodoItemViewModel>(entityName: "TodoItem", keyForSort: "index", sectionKey: "priority")
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
            case let .row(rowChangeType):
                switch rowChangeType {
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
            case let .section(sectionChangeType):
                switch sectionChangeType {
                case let .delete(index):
                    self?.tableView.deleteSections(IndexSet(integer: index), with: .automatic)
                case let .insert(index):
                    self?.tableView.insertSections(IndexSet(integer: index), with: .automatic)
                case let .error(error):
                    print(error)
                }
            }
        }
    }
    
    func fetch() {
        coreDataController.fetch()
    }
    
    func addTodoItem(name: String) {
        let item = TodoItem()
        item.text = name
        item.priority = TodoItemViewModel.Prioroty.medium.sectionName
        item.index = 0
        let numberOfItems = coreDataController.numberOfItems(in: 1)
        for index in 0..<numberOfItems {
            let indexPath = IndexPath(item: index, section: 1)
            coreDataController.updateModel(indexPath: indexPath) { (item) in
                item.index = Int32(index + 1)
            }
        }
        coreDataController.add(model: item)
    }
    
    func deleteTodoItems(at indexPaths: [IndexPath]) {
        coreDataController.deleteItems(at: indexPaths)
    }
    
    func editItemName(
        indexPath: IndexPath,
        text: String,
        isChecked: Bool,
        priority: String
        ) {
        coreDataController.updateModel(indexPath: indexPath) { (todoItem) in
            todoItem.text = text
            todoItem.isChecked = isChecked
            todoItem.priority = priority
        }
    }
}

extension TodoItemDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataController.numberOfItems(in: section)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return coreDataController.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = coreDataController.getItem(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell", for: indexPath) as! TodoItemTableViewCell
        cell.configure(with: vm)
        cell.editItemCallback = { [weak self] text in
            self?.editItemName(
                indexPath: indexPath,
                text: text ?? "",
                isChecked: vm.isChecked,
                priority: vm.priority.rawValue
            )
        }
        cell.checkBoxCallback = { [weak self] in
            self?.editItemName(
                indexPath: indexPath,
                text: vm.text,
                isChecked: !vm.isChecked,
                priority: vm.priority.rawValue
            )
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteTodoItems(at: [indexPath])
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionName = coreDataController.nameForSection(at: section) {
            let title = TodoItemViewModel.Prioroty.init(sectionName: sectionName)
            return title.rawValue.capitalized
        } else {
            return nil
        }
    }
    
    //TODO: add moveRowAt func
}
