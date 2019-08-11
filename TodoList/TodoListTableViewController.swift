import UIKit

class TodoListTableViewController: UITableViewController {
    var dataSource: TodoItemDataSource!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func deleteFewItems(_ sender: UIBarButtonItem) {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            dataSource.deleteTodoItems(at: selectedRows)
        }
    }
    
    @IBAction func edit(_ button: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
        dataSource.shouldDisplayAllSections = isEditing
        updateEditButton()
        updateDeleteButtonState()
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        let aivc = AddItemTableViewController { [weak self] (name) in
            self?.dataSource.addTodoItem(name: name)
        }
        self.navigationController?.pushViewController(aivc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateEditButton()
        deleteButton.isEnabled = false
        dataSource = TodoItemDataSource(tableView: self.tableView)
        dataSource.fetch()
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        updateDeleteButtonState()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateDeleteButtonState()
    }
    
    private func updateDeleteButtonState() {
        let selectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
        deleteButton.isEnabled = tableView.isEditing && selectedRows > 0
    }
    
    private func updateEditButton() {
        editButton.title = isEditing ? "Done" : "Edit"
    }
}
