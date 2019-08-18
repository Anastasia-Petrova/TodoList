import Foundation

struct CreateTodoViewModel {
    var title: String
    var selectedSegmentIndex: Int
    var priority: TodoItemPriority {
        return allPriorities[selectedSegmentIndex]
    }
    var reminderTime: Date?
    let labels = Labels()
    private let allPriorities: [TodoItemPriority]
    var isReminderTimeHidden: Bool {
        return reminderTime == nil
    }
    var isReminderOn: Bool {
        didSet {
            if isReminderOn {
                reminderTime = Date()
            } else {
                reminderTime = nil
            }
        }
    }
    var isDoneButtonEnabled: Bool {
        return !title.isEmpty
    }
    var prioritySegmentControlItems: [String] {
        return allPriorities.map { $0.rawValue.capitalized }
    }
}

extension CreateTodoViewModel {
    init() {
        title = ""
        selectedSegmentIndex = 1
        reminderTime = nil
        allPriorities = TodoItemPriority.allCases.dropLast()
        isReminderOn = false
    }
}

extension CreateTodoViewModel {
    struct Labels {
        let doneButton = "Done"
        let cancelButton = "Cancel"
        let titlePlaceholder = "What's on your mind?"
        let reminder = "Remind me on a day"
        let screenTitle = "Add New Todo"
    }
}
