struct TodoItemViewModel  {
    let text: String
    let isChecked: Bool
}

extension TodoItemViewModel: CoreDataMappable {
    typealias CoreDataModel = TodoItem
    
    init(model: TodoItem) {
        text = model.name ?? ""
        isChecked = false //TODO: Add isChecked to DB
    }
}