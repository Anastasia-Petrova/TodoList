import UIKit

class AddItemTableViewController: UITableViewController {
    typealias AddItemCallback = (String, Int) -> Void
    var viewModel: CreateTodoViewModel {
        didSet {
            self.view.setNeedsLayout()
            if oldValue.isReminderTimeHidden != viewModel.isReminderTimeHidden {
                let isReminderTimeHidden = viewModel.isReminderTimeHidden
                tableView.beginUpdates()
                    if isReminderTimeHidden {
                        tableView.deleteRows(at: [IndexPath(row: 1, section: 2)], with: .top)
                    } else {
                        tableView.insertRows(at: [IndexPath(row: 1, section: 2)], with: .top)
                    }
               tableView.endUpdates()
            }
        }
    }
    let doneButton: UIBarButtonItem
    let cancelButton: UIBarButtonItem
    let textField: UITextField
    let prioritySegmentedControl: UISegmentedControl
    let reminderToggle: UISwitch
    let picker: UIPickerView
    var editingItemName = ""
    
    @objc func priorityChanged() {
        viewModel.selectedSegmentIndex = prioritySegmentedControl.selectedSegmentIndex
    }
    
    @objc func reminderToggleChanged() {
        viewModel.isReminderOn = reminderToggle.isOn
    }

    
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
    
    init(viewModel: CreateTodoViewModel, addItemCallBack: @escaping AddItemCallback) {
        self.viewModel = viewModel
        self.addItemCallback = addItemCallBack
        textField = UITextField()
        textField.font = .systemFont(ofSize: 24, weight: .light)
        doneButton = UIBarButtonItem()
        cancelButton = UIBarButtonItem()
        prioritySegmentedControl = UISegmentedControl(items: viewModel.prioritySegmentControlItems)
        reminderToggle = UISwitch()
        picker = UIPickerView()
        super.init(style: .grouped)
        self.title = viewModel.labels.screenTitle
        picker.delegate = self
        picker.dataSource = self
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prioritySegmentedControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
        doneButton.isEnabled = viewModel.isDoneButtonEnabled
        reminderToggle.isOn = viewModel.isReminderOn
    }

    private func setUpSubviews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = viewModel.labels.titlePlaceholder
        prioritySegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        prioritySegmentedControl.addTarget(self, action: #selector(priorityChanged), for: .valueChanged)
        doneButton.title = viewModel.labels.doneButton
        doneButton.style = .done
        doneButton.target = self
        doneButton.action = #selector(done)
        cancelButton.title = viewModel.labels.cancelButton
        cancelButton.style = .plain
        cancelButton.target = self
        cancelButton.action = #selector(cancel)
        reminderToggle.addTarget(self, action: #selector(reminderToggleChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 200
        } else {
            return 44.0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return createNameCell()
        case 1:
            return createPriorityCell()
        case 2:
            if indexPath.row == 0 {
                return createTimerCell()
            } else {
                return createPickerCell()
            }
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
            cell.topAnchor.constraint(equalTo: prioritySegmentedControl.topAnchor, constant: -6),
            cell.bottomAnchor.constraint(equalTo: prioritySegmentedControl.bottomAnchor, constant: 6),
            cell.trailingAnchor.constraint(equalTo: prioritySegmentedControl.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: prioritySegmentedControl.leadingAnchor, constant: -16)
            ])
        return cell
    }
    
    private func createTimerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        let reminderLabel = UILabel()
        reminderLabel.font = .systemFont(ofSize: 18, weight: .light)
        reminderLabel.text = viewModel.labels.reminder
        let stackView = UIStackView(arrangedSubviews: [reminderLabel, reminderToggle])
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
    
    private func createPickerCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.topAnchor.constraint(equalTo: picker.topAnchor, constant: -6),
            cell.bottomAnchor.constraint(equalTo: picker.bottomAnchor, constant: 6),
            cell.trailingAnchor.constraint(equalTo: picker.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: picker.leadingAnchor, constant: -16)
            ])
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return viewModel.isReminderOn ? 2 : 1
        } else {
            return 1
        }
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
        let newTitle = oldText.replacingCharacters(in: stringRange, with: string)
        viewModel.title = newTitle
        return true
    }
}

extension AddItemTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    
}
