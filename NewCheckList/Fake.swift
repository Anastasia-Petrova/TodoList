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

struct Human {
    let name: String
}

enum Fruit {
    case apple(Double)
}

var catLeo = Cat(dog: .pug)
var catTiger = Cat.tiger
var catPanther = Cat(dog: .shuber)
var human = Human(name: "Alex")
