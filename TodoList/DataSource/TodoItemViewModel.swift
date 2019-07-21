import EasyCoreData

struct TodoItemViewModel  {
    let text: String
    let isChecked: Bool
    let priority: Prioroty
}

extension TodoItemViewModel {
    var checkBoxIconName: String {
        return isChecked ? "checkedMark" : "uncheckedMark"
    }
}

extension TodoItemViewModel: CoreDataMappable {
    typealias CoreDataModel = TodoItem
    
    init(model: TodoItem) {
        text = model.text ?? ""
        isChecked = model.isChecked
        let defaultPriority = Prioroty.high
        if let priorityString = model.priority {
            priority = Prioroty(rawValue: priorityString) ?? defaultPriority
        } else {
            priority = defaultPriority
        }
    }
}

extension TodoItemViewModel {
    enum Prioroty: String {
        case high
        case medium
        case low
    }
}
