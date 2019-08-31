import Foundation

struct CreateTodoViewModel {
    let mode: Mode
    var title: String
    var selectedSegmentIndex: Int
    var priority: TodoItemPriority {
        return allPriorities[selectedSegmentIndex]
    }
    var reminderTime: Date?
    let labels = Labels()
    private let allPriorities: [TodoItemPriority]
    var hasReminder: Bool {
        return reminderTime != nil
    }
    var isDoneButtonEnabled: Bool {
        return !title.isEmpty
    }
    var prioritySegmentControlItems: [String] {
        return allPriorities.map { $0.rawValue.capitalized }
    }
}

extension CreateTodoViewModel {
    init(mode: Mode) {
        selectedSegmentIndex = 1
        allPriorities = TodoItemPriority.allCases.dropLast()
        self.mode = mode
        switch mode {
        case .create:
            title = ""
            reminderTime = nil
        case let .edit(title, date):
            self.title = title
            reminderTime = date
        }
    }
}

extension CreateTodoViewModel {
    struct Labels {
        let doneButton = "Done"
        let cancelButton = "Cancel"
        let titlePlaceholder = "What's on your mind?"
        let reminder = "Remind me on a day"
        let screenTitle = "Add New Todo"
        let editScreenTitle = "Edit Todo"
    }
}

extension CreateTodoViewModel {
    enum Mode: Equatable {
        static func == (lhs: CreateTodoViewModel.Mode, rhs: CreateTodoViewModel.Mode) -> Bool {
            switch (lhs, rhs)  {
            case (.create, .create):
                return true
            case let (.edit(lhsTitle, lhsDate), .edit(rhsTitle, rhsDate)):
                return lhsTitle == rhsTitle && lhsDate == rhsDate
            default:
                return false
            }
        }
        
        case create
        case edit(title: String, date: Date?)
    }
}
