import UIKit
import CoreData

class TodoListTableViewController: UITableViewController {
    var dataSource: TodoItemDataSource!
    
    @IBAction func deleteFewItems(_ sender: UIBarButtonItem) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            delete(items: selectedRows)
        }
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let aivc = storyboard.instantiateViewController(withIdentifier: "AddItemTableViewController") as! AddItemTableViewController
        aivc.addItemCallback = { [weak self] (name) in
            self?.dataSource.addTodoItem(name: name)
        }
        self.navigationController?.pushViewController(aivc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = TodoItemDataSource(tableView: self.tableView)
        dataSource.fetch()
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//            let item = TodoItem(context: CoreDataManager.instance.managedObjectContext)
//        var items = [item]
//        items.remove(at: sourceIndexPath.row)
//        items.insert(item, at: destinationIndexPath.row)
//        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        let cell = tableView.cellForRow(at: indexPath) as! TodoItemTableViewCell
//        if cell.checkmark.text == "" {
//            cell.checkmark.text = "√"
//        } else {
//            cell.checkmark.text = ""
//        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.deleteItem(indexPath: indexPath)
    }
    
    func deleteItem(indexPath: IndexPath) {
//        let item = todoListFetchController.object(at: indexPath)
//        CoreDataManager.instance.managedObjectContext.delete(item)
//        CoreDataManager.instance.saveContext()
    }
    
    func delete(items indexPaths: [IndexPath]) {
//        indexPaths
//        .map(todoListFetchController.object)
//        .forEach(CoreDataManager.instance.managedObjectContext.delete)
//        CoreDataManager.instance.saveContext()
    }
}



