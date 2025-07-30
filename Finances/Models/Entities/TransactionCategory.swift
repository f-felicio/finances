import UIKit

enum TransactionCategory: String, CaseIterable {
    case salario = "salary"
    case compras = "shopping"
    case presente = "gift"
    case contas = "bills"
    case moradia = "home"
    
    var displayName: String {
        switch self {
        case .salario:
            return "Salary"
        case .compras:
            return "Shopping"
        case .presente:
            return "Gift"
        case .contas:
            return "Bill"
        case .moradia:
            return "Home"
        }
    }
    
    var type: TransactionType {
        switch self {
        case .salario:
            return .income
        case .compras, .presente, .contas, .moradia:
            return .expense
        }
    }
    
    var icon: UIImage? {
        let named: String
        switch self {
        case .salario:
            named = "briefcase"
        case .compras:
            named = "basket"
        case .presente:
            named = "gift"
        case .contas:
            named = "empty-file"
        case .moradia:
            named = "home"
        }
        return UIImage(named: named)
    }
    
    // Helper function to filter categories by type
    static func categories(for type: TransactionType) -> [TransactionCategory] {
        return TransactionCategory.allCases.filter { $0.type == type }
    }
}
