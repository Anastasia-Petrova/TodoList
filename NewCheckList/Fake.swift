struct TodoItemDataSource {
    init() {
        let cdc = CoreDataController<TodoItem>(
            entityName: "TodoItem",
            keyForSort: "name"
        )
        cdc.beginUpdate = {
            //tableView.beginUpdate()
        }
        cdc.endUpdate = {
            //tableView.endUpdate()
        }
        cdc.changeCallback = { change in
            //tableView.insertItem(
        }
    }
}













enum Cat {
    case panther
    case tiger
    case leo
    
    init(dog: Dog) {
        switch dog {
        case .pug:
            self = .leo
        case .shiba:
            self = .tiger
        case .shuber:
            self = .panther
        }
    }
}

enum Dog {
    case pug
    case shuber
    case shiba
}

let catLeo = Cat(dog: .pug)
let catPanther = Cat(dog: .shuber)

