import UIKit

class TodoListTableViewController: UITableViewController {
    var dataSource: TodoItemDataSource!
    
    @IBAction func edit(_ button: UIBarButtonItem) {
        setEditing(!isEditing, animated: true)
        dataSource.shouldDisplayAllSections = isEditing
        updateEditButton()
    }
    
    @IBOutlet weak var editButton: UIBarButtonItem!
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
        updateEditButton()
        dataSource = TodoItemDataSource(tableView: self.tableView)
        dataSource.fetch()
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func updateEditButton() {
        editButton.title = isEditing ? "Done" : "Edit"
    }
}
