import UIKit
import EasyCoreData

public final class TodoItemDataSource: NSObject {
    let coreDataController: CoreDataController<TodoItem, TodoItemViewModel>
    let tableView: UITableView
    var shouldListenDataBaseUpdates = true
    
    init(tableView: UITableView) {
        coreDataController = CoreDataController<TodoItem, TodoItemViewModel>(entityName: "TodoItem", keyForSort: "index", sectionKey: "priority")
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        coreDataController.beginUpdate = { [weak self] in
            guard self?.shouldListenDataBaseUpdates == true else { return }
            self?.tableView.beginUpdates()
        }
        coreDataController.endUpdate = { [weak self] in
            guard self?.shouldListenDataBaseUpdates == true else { return }
            self?.tableView.endUpdates()
        }
        coreDataController.changeCallback = { [weak self] change in
            guard self?.shouldListenDataBaseUpdates == true else { return }
            switch change.type {
            case let .row(rowChangeType):
                switch rowChangeType {
                case let .delete(indexPath):
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                case let .insert(indexPath):
                    self?.tableView.insertRows(at: [indexPath], with: .automatic)
                case let .move(fromIndexPath, toIndexPath):
                    self?.tableView.deleteRows(at: [fromIndexPath], with: .automatic)
                    self?.tableView.insertRows(at: [toIndexPath], with: .automatic)
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
        let sectionIndex = coreDataController.indexForSectionName(name: TodoItemViewModel.Prioroty.medium.sectionName) ?? 0
        
        let item = TodoItem()
        item.text = name
        item.priority = TodoItemViewModel.Prioroty.medium.sectionName
        item.index = 0
        
        let numberOfItems = coreDataController.numberOfItems(in: sectionIndex)
        let indexPaths = (0..<numberOfItems).map{ IndexPath(row: $0, section: sectionIndex) }
        coreDataController.updateModels(indexPaths: indexPaths) { (items) in
            items.forEach {
                $0.index += 1
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
        coreDataController.updateModels(indexPaths: [indexPath]) { (todoItems) in
            todoItems.first?.text = text
            todoItems.first?.isChecked = isChecked
            todoItems.first?.priority = priority
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
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let isMovingUp = destinationIndexPath.row < sourceIndexPath.row
        let startIndex = isMovingUp ? destinationIndexPath.row : sourceIndexPath.row
        let endIndex = isMovingUp ? sourceIndexPath.row : destinationIndexPath.row
        let sectionIndex = destinationIndexPath.section
        let indexPaths = (startIndex...endIndex).map{ IndexPath(row: $0, section: sectionIndex) }
        
        shouldListenDataBaseUpdates = false
        coreDataController.updateModels(indexPaths: indexPaths) { (items) in
            let movingItem = isMovingUp ? items.last : items.first
            items.forEach {
                $0.index += isMovingUp ? 1 : -1
                $0.priority = coreDataController.nameForSection(at: destinationIndexPath.section)
            }
            movingItem?.index = Int32(destinationIndexPath.row)
            movingItem?.priority = coreDataController.nameForSection(at: destinationIndexPath.section)
        }
        shouldListenDataBaseUpdates = true
    }
}
