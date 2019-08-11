import EasyCoreData

struct TodoItemViewModel  {
    let text: String
    let isChecked: Bool
    let priority: TodoItemPriority
    let index: Int
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
        let defaultPriority = TodoItemPriority.medium
        if let priorityString = model.priority {
            priority = TodoItemPriority(sectionName: priorityString)
        } else {
            priority = defaultPriority
        }
        index = Int(model.index)
    }
}

