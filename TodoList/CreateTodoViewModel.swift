import Foundation

struct CreateTodoViewModel {
    let title: String
    let priority: TodoItemPriority
    let reminderTime: Date?
    let labels = Labels()
    var isReminderOn: Bool {
        return reminderTime != nil
    }
    var isDoneButtonActive: Bool {
        return !title.isEmpty
    }
}

extension CreateTodoViewModel {
    init() {
        title = ""
        priority = .medium
        reminderTime = nil
    }
}

extension CreateTodoViewModel {
    struct Labels {
        let doneButton = "Done"
        let cancelButton = "Cancel"
        let titlePlaceholder = "What's on your mind?"
        let prioritySegmentControlItems = TodoItemPriority.allCases.map { $0.rawValue.capitalized }.dropLast()
        let reminder = "Remind me on a day"
        let screenTitle = "Add New Todo"
    }
}
