import EasyCoreData

struct TodoItemViewModel  {
    let text: String
    let isChecked: Bool
    let priority: Prioroty
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
        let defaultPriority = Prioroty.medium
        if let priorityString = model.priority {
            priority = Prioroty(sectionName: priorityString)
        } else {
            priority = defaultPriority
        }
        index = Int(model.index)
    }
}

extension TodoItemViewModel {
    enum Prioroty: String {
        case high
        case medium
        case low
        
        var sectionName: String {
            switch self {
            case .high:
                return "a"
            case .medium:
                return "b"
            case .low:
                return "c"
            }
        }
        
        init(sectionName: String) {
            switch sectionName {
            case "a":
                self = .high
            case "b":
                self = .medium
            case "c":
                self = .low
            default:
                self = .medium
            }
        }
    }
}
