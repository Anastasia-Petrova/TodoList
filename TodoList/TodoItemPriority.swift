enum TodoItemPriority: String, CaseIterable {
    case high
    case medium
    case low
    case done
    
    var sectionName: String {
        switch self {
        case .high:
            return "a"
        case .medium:
            return "b"
        case .low:
            return "c"
        case .done:
            return "d"
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
        case "d":
            self = .done
        default:
            self = .medium
        }
    }
}
