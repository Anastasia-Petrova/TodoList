enum TodoItemPriority: String, CaseIterable {
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
