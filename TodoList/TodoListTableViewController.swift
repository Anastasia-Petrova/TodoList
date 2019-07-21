import UIKit

class TodoListTableViewController: UITableViewController {
    var dataSource: TodoItemDataSource!
    
    @IBAction func deleteFewItems(_ sender: UIBarButtonItem) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            dataSource.deleteTodoItems(at: selectedRows)
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
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.cellForRow(at: indexPath) as! TodoItemTableViewCell
//        if cell.checkmark.text == "" {
//            cell.checkmark.text = "√"
//        } else {
//            cell.checkmark.text = ""
//        }
    }
}


