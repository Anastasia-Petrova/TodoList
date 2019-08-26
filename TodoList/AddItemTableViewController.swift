import UIKit

class AddItemTableViewController: UITableViewController {
    typealias AddItemCallback = (String, Int, Date?) -> Void
    var viewModel: CreateTodoViewModel {
        didSet {
            self.view.setNeedsLayout()
        }
    }
    let doneButton: UIBarButtonItem
    let cancelButton: UIBarButtonItem
    let textField: UITextField
    let prioritySegmentedControl: UISegmentedControl
    let reminderToggle: UISwitch
    let picker: UIDatePicker
    var editingItemName = ""
    let hours = (0...23).map { String($0) }
    let minutes = (1...59).map { String($0) }

    
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
            let reminderTime = picker.isHidden ? nil : picker.date
            addItemCallback(newName, priorityIndex, reminderTime)
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
        picker = UIDatePicker()
        super.init(style: .grouped)
        self.tableView.allowsSelection = false
        self.title = viewModel.labels.screenTitle
        picker.isHidden = viewModel.isReminderTimeHidden
        setUpSubviews()
        switch viewModel.mode {
        case let .edit(title, date, callBack):
            setUpForEditingMode(title: title, date: date)
        case .create:
            break
        }
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
    
    func setUpForEditingMode(title: String, date: Date?) {
        textField.text = title
        if let newDate = date {
            picker.date = newDate
        }
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prioritySegmentedControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
        doneButton.isEnabled = viewModel.isDoneButtonEnabled
        reminderToggle.isOn = viewModel.isReminderOn
        let wasPickerHidden = picker.isHidden
        picker.isHidden = viewModel.isReminderTimeHidden
        if wasPickerHidden != viewModel.isReminderTimeHidden {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
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
        picker.timeZone = NSTimeZone.local
        picker.addTarget(self, action: #selector(AddItemTableViewController.datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
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
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let selectedDate: String = dateFormatter.string(from: sender.date)
        print("Selected value \(selectedDate)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
            cell.topAnchor.constraint(equalTo: textField.topAnchor, constant: -6),
            cell.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 6),
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
        let hStackView = UIStackView(arrangedSubviews: [reminderLabel, reminderToggle])
        hStackView.setContentCompressionResistancePriority(.required, for: .vertical)
        hStackView.alignment = .center
        hStackView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(hStackView)
        let vStackView = UIStackView(arrangedSubviews: [picker])
        vStackView.axis = .vertical
        vStackView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(vStackView)
        NSLayoutConstraint.activate([
            reminderLabel.heightAnchor.constraint(equalToConstant: 32),
            cell.topAnchor.constraint(equalTo: hStackView.topAnchor, constant: -6),
            cell.trailingAnchor.constraint(equalTo: hStackView.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: hStackView.leadingAnchor, constant: -16),
            hStackView.bottomAnchor.constraint(equalTo: vStackView.topAnchor, constant: 0),
            cell.bottomAnchor.constraint(equalTo: vStackView.bottomAnchor, constant: 6),
            cell.trailingAnchor.constraint(equalTo: vStackView.trailingAnchor, constant: 16),
            cell.leadingAnchor.constraint(equalTo: vStackView.leadingAnchor, constant: -16)
            ])
        
        return cell
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


    



