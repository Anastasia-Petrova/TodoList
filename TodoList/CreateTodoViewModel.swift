import Foundation

struct CreateTodoViewModel {
    let title: String
    let priority: TodoItemPriority
    let reminderTime: Date?
}

extension CreateTodoViewModel {
    init() {
        title = ""
        priority = .medium
        reminderTime = nil
    }
}
