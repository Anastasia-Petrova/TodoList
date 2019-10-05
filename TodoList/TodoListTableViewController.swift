import UIKit

class TodoListTableViewController: UITableViewController {
    var dataSource: TodoItemDataSource!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
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
        let mode = CreateTodoViewModel.Mode.create { [weak self] (name, priorityIndex, remindDate) in
            self?.dataSource.addTodoItem(name: name, prioritIndex: priorityIndex, remindDate: remindDate)
        }
        let viewModel = CreateTodoViewModel(mode: mode)
        navigateToAddItemScreen(viewModel: viewModel)
    }
    
    func navigateToAddItemScreen(viewModel: CreateTodoViewModel) {
        let aivc = AddItemTableViewController(viewModel: viewModel)
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
        if isEditing {
            updateDeleteButtonState()
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            let itemInfo = dataSource.getItemInfo(indexPath: indexPath)
            let mode = CreateTodoViewModel.Mode.edit(title: itemInfo.text, date: itemInfo.reminindDate) { [weak self] (title, date) in
                self?.dataSource.updateItem(
                    indexPath: indexPath,
                    text: title,
                    isChecked: itemInfo.isChecked,
                    priority: itemInfo.priority,
                    reminderTime: date
                )
                let url = itemInfo.url.absoluteString
                if let notificationDate = date {
                    self?.appDelegate?.scheduleNotification(notificationBody: itemInfo.text, notificationDate: notificationDate, userInfo: ["url" : url], identifier: url)
                }
            }
            let viewModel = CreateTodoViewModel(mode: mode)
            navigateToAddItemScreen(viewModel: viewModel)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            updateDeleteButtonState()
        }
    }
    
    private func updateDeleteButtonState() {
        let selectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
        deleteButton.isEnabled = tableView.isEditing && selectedRows > 0
    }
    
    private func updateEditButton() {
        editButton.title = isEditing ? "Done" : "Edit"
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard dataSource.canPerfornCheckAction(indexPath: indexPath) else {
            return nil
        }
        let contextItem = UIContextualAction(style: .normal, title: "Done") { [weak self] (_, _, hasPerformedAction) in
            self?.dataSource.done(at: indexPath)
            hasPerformedAction(true)
        }
        contextItem.backgroundColor = UIColor.blue
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        return swipeActions
    }
}
