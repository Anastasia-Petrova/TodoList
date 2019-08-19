import UIKit

class AddItemTableViewController: UITableViewController {
    typealias AddItemCallback = (String, Int) -> Void
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
    let picker: UIPickerView
    var editingItemName = ""
    let hours = (0...23).map { String($0) }
    let minutes = (1...59).map { String($0) }
    let currentDate = Date()
    
//    let days = []
    
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
        self.tableView.allowsSelection = false
        self.title = viewModel.labels.screenTitle
        picker.delegate = self
        picker.dataSource = self
        picker.isHidden = viewModel.isReminderTimeHidden
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

extension AddItemTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return generateDatesArray().count
        case 1:
            return hours.count
        case 2:
            return minutes.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            let fmt = DateFormatter()
            fmt.dateFormat = "MMM d, yyyy"
            let title = generateDatesArray()[row]
            let result = fmt.string(from: title)
            return result
        case 1:
            return hours[row]
        case 2:
            return minutes[row]
        default:
            return ""
        }
    }
    
    func generateDatesArray() -> [Date] {
        var datesArray: [Date] = [Date]()
        var startDate = Date()
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 8
        dateComponents.day = 19
        let calendar = Calendar.current
        let endDate = calendar.date(from: dateComponents)!
        
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        
        while startDate <= endDate {
            datesArray.append(startDate)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
    
        }
        return datesArray
    }
}
    



