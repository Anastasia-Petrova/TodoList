import UIKit

class AddItemTableViewController: UITableViewController {
    typealias AddItemCallback = (String, Int) -> Void
    let doneButton: UIBarButtonItem
    let cancelButton: UIBarButtonItem
    let textField: UITextField
    let prioritySegmentedControl: UISegmentedControl
    let reminderLabel: UILabel
    let reminderTogle: UISwitch
    
    var editingItemName = ""
    
    @objc func done() {
        self.navigationController?.popViewController(animated: true)
        if let newName = textField.text {
            let priorityIndex = prioritySegmentedControl.selectedSegmentIndex
            addItemCallback(newName, priorityIndex)
        }
    }
    
    @objc func cancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    var addItemCallback: AddItemCallback
    
    init(addItemCallBack: @escaping AddItemCallback) {
        self.addItemCallback = addItemCallBack
        textField = UITextField()
        textField.font = .systemFont(ofSize: 24, weight: .light)
        doneButton = UIBarButtonItem()
        cancelButton = UIBarButtonItem()
        prioritySegmentedControl = UISegmentedControl(items: TodoItemPriority.allCases.map { $0.rawValue.capitalized }.dropLast())
        reminderLabel = UILabel()
        reminderTogle = UISwitch()
        super.init(style: .grouped)
        self.title = "Add New Todo"
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.text = editingItemName
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }

    private func setUpSubviews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "What's on your mind?"
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySegmentedControl.selectedSegmentIndex = 1
        reminderLabel.font = .systemFont(ofSize: 18)
        reminderLabel.text = "Remind me on a day"
        doneButton.title = "Done"
        doneButton.style = .done
        doneButton.target = self
        doneButton.action = #selector(done)
        cancelButton.title = "Cancel"
        cancelButton.style = .plain
        cancelButton.target = self
        cancelButton.action = #selector(cancel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return createNameCell()
        case 1:
            return createPriorityCell()
        case 2:
            return createTimerCell()
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Choose priority"
        }
        return nil
    }
    
    private func createNameCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.addSubview(textField)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: textField.topAnchor),
            cell.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
            cell.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -16)
            ])
        return cell
    }
    
    private func createPriorityCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.addSubview(prioritySegmentedControl)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: prioritySegmentedControl.topAnchor),
            cell.bottomAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor),
            cell.trailingAnchor.constraint(equalTo: prioritySegmentedControl.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: prioritySegmentedControl.leadingAnchor, constant: -16)
            ])
        return cell
    }
    
    private func createTimerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        let stackView = UIStackView(arrangedSubviews: [reminderLabel, reminderTogle])
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(stackView)
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: stackView.topAnchor),
            cell.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            cell.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -16)
            ])
    
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension AddItemTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
            let stringRange = Range(range, in: oldText) else {
                return false
        }
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
        return true
    }
}
