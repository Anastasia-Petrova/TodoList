import UIKit
import EasyCoreData

public final class TodoItemDataSource: NSObject {
    let coreDataController: CoreDataController<TodoItem, TodoItemViewModel>
    let tableView: UITableView
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var shouldListenDataBaseUpdates = true
    var shouldDisplayAllSections: Bool {
        didSet{
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        coreDataController = CoreDataController<TodoItem, TodoItemViewModel>(entityName: "TodoItem", keyForSort: "index", sectionKey: "priority")
        self.tableView = tableView
        shouldDisplayAllSections = tableView.isEditing
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
    
    func canPerfornCheckAction(indexPath: IndexPath) -> Bool {
        return coreDataController.nameForSection(at: indexPath.section) != TodoItemPriority.done.sectionName
    }
    
    func addTodoItem(name: String, prioritIndex: Int, remindDate: Date?) {
        let item = TodoItem()
        item.text = name
        item.priority = TodoItemPriority.allCases[prioritIndex].sectionName
        item.index = 0
        item.isChecked = false
        item.remindDate = remindDate
        coreDataController.add(model: item)
        let url = item.objectID.uriRepresentation().absoluteString
        if let notificationDate = remindDate {
            appDelegate?.scheduleNotification(notificationBody: name, notificationDate: notificationDate, userInfo: ["url" : url], identifier: url)
        }
        
        if let sectionIndex = coreDataController.indexForSectionName(name: TodoItemPriority.allCases[prioritIndex].sectionName) {
            let numberOfItems = coreDataController.numberOfItems(in: sectionIndex)
            let indexPaths = (1..<numberOfItems).map { IndexPath(row: $0, section: sectionIndex) }
            coreDataController.updateModels(indexPaths: indexPaths) { (items) in
                items.forEach {
                    $0.index += 1
                }
            }
        }
    }
    
    func deleteTodoItems(at indexPaths: [IndexPath]) {
        coreDataController.deleteItems(at: indexPaths)
        let sections = indexPaths.reduce(Set<Int>()) { $0.union([$1.section]) }
        for section in sections {
            let numberOfItems = coreDataController.numberOfItems(in: section)
            let newIndexPaths = (0..<numberOfItems).map{ IndexPath(row: $0, section: section) }
            coreDataController.updateModels(indexPaths: newIndexPaths) { (items) in
                for (index, item) in items.enumerated() {
                    item.index = Int32(index)
                }
            }
        }
    }
    
    func done(at indexPath: IndexPath) {
        coreDataController.updateModels(indexPaths: [indexPath]) { (todoItems) in
            todoItems.first?.index = 0
            todoItems.first?.isChecked = true
            todoItems.first?.priority = TodoItemPriority.done.sectionName
        }
        
        if let sectionIndex = coreDataController.indexForSectionName(name: TodoItemPriority.done.sectionName) {
            let numberOfItems = coreDataController.numberOfItems(in: sectionIndex)
            let indexPaths = (1..<numberOfItems).map{ IndexPath(row: $0, section: sectionIndex) }
            coreDataController.updateModels(indexPaths: indexPaths) { (items) in
                items.forEach {
                    $0.index += 1
                }
            }
        }
    }
    
    func updateItem(indexPath: IndexPath,
                            text: String,
                            isChecked: Bool,
                            priority: TodoItemPriority,
                            reminderTime: Date?
        ) {
        coreDataController.updateModels(indexPaths: [indexPath]) { (todoItems) in
            todoItems.first?.text = text
            todoItems.first?.isChecked = isChecked
            todoItems.first?.priority = priority.sectionName
            todoItems.first?.remindDate = reminderTime
        }
    }
    
    func getItemInfo(indexPath: IndexPath) -> (TodoItemViewModel) {
        return coreDataController.getItem(at: indexPath)
    }
}

extension TodoItemDataSource: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if shouldDisplayAllSections {
            return TodoItemPriority.allCases[section].rawValue.capitalized
        } else {
            var name = ""
            if let coreSectionName = coreDataController.nameForSection(at: section) {
                name = TodoItemPriority(sectionName: coreSectionName).rawValue.capitalized
            }
            return name
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldDisplayAllSections {
            let sectionName = TodoItemPriority.allCases[section].sectionName
            if let realSectionIndex = coreDataController.indexForSectionName(name: sectionName) {
                return coreDataController.numberOfItems(in: realSectionIndex)
            } else {
                return 0
            }
        } else {
            return coreDataController.numberOfItems(in: section)
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return shouldDisplayAllSections ? TodoItemPriority.allCases.count : coreDataController.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexPathForDataBase: IndexPath
        if shouldDisplayAllSections {
            let sectionName = TodoItemPriority.allCases[indexPath.section].sectionName
            let realSectionIndex = coreDataController.indexForSectionName(name: sectionName)!
            indexPathForDataBase = IndexPath(row: indexPath.row, section: realSectionIndex)
        } else {
            indexPathForDataBase = indexPath
        }
        
        let vm = coreDataController.getItem(at: indexPathForDataBase)
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemTableViewCell", for: indexPath) as! TodoItemTableViewCell
        cell.configure(with: vm, shouldAllowEditingText: !shouldDisplayAllSections)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        deleteTodoItems(at: [indexPath])
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        shouldListenDataBaseUpdates = false
        let destionationSectionIndex = destinationIndexPath.section
        if sourceIndexPath.section == destinationIndexPath.section {
            let isMovingUp = destinationIndexPath.row < sourceIndexPath.row
            let startIndex = isMovingUp ? destinationIndexPath.row : sourceIndexPath.row
            let endIndex = isMovingUp ? sourceIndexPath.row : destinationIndexPath.row
            let sectionIndex = destinationIndexPath.section
            let indexPaths = (startIndex...endIndex).map{ IndexPath(row: $0, section: sectionIndex) }
            
            //All right
            coreDataController.updateModels(indexPaths: indexPaths) { (items) in
                let movingItem = isMovingUp ? items.last : items.first
                items.forEach {
                    $0.index += isMovingUp ? 1 : -1
                    $0.priority = coreDataController.nameForSection(at: destinationIndexPath.section)
                }
                movingItem?.index = Int32(destinationIndexPath.row)
                movingItem?.priority = TodoItemPriority.allCases[destionationSectionIndex].sectionName
            }
        } else {
            let numberOfItemsInDestinationSection = coreDataController.numberOfItems(in: destinationIndexPath.section)
            let isEmptyDescinationSection = numberOfItemsInDestinationSection == 0
            let indexOfLastElementInDestinationSection = isEmptyDescinationSection ? 0 : numberOfItemsInDestinationSection - 1

            let endIndexForSourceSection = coreDataController.numberOfItems(in: sourceIndexPath.section) - 1
            let sourceSectionIndexPaths = (sourceIndexPath.row...endIndexForSourceSection).map{ IndexPath(row: $0, section: sourceIndexPath.section) }
            let destinationUpperBound: Int
            if destinationIndexPath.row > indexOfLastElementInDestinationSection {
                destinationUpperBound = destinationIndexPath.row
            } else {
                destinationUpperBound = indexOfLastElementInDestinationSection
            }
            let destinationSectionIndexPaths = (destinationIndexPath.row...destinationUpperBound).map{ IndexPath(row: $0, section: destionationSectionIndex) }
            
            print("sourceSectionIndexPaths: \(sourceSectionIndexPaths)")
            print("destinationSectionIndexPaths: \(destinationSectionIndexPaths)")
            coreDataController.updateModels(indexPaths: destinationSectionIndexPaths) { (items) in
                items.forEach {
                    $0.index += 1
                }
            }
            coreDataController.updateModels(indexPaths: sourceSectionIndexPaths) { (items) in
                let movingItem = items.first
                items.forEach {
                    $0.index -= 1
                }
                movingItem?.index = Int32(destinationIndexPath.row)
                movingItem?.priority = TodoItemPriority.allCases[destionationSectionIndex].sectionName
                if TodoItemPriority.allCases[destionationSectionIndex] == TodoItemPriority.done {
                    movingItem?.isChecked = true
                } else {
                    movingItem?.isChecked = false
                }
            }
        }
        shouldListenDataBaseUpdates = true
    }
}
