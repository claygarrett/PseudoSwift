
// MARK: - Outlet
import UIKit
import PseudoSwift

enum OutletType: Int {
    case inputValue
    case outputValue
    case inputFlow
    case outputFlow
    
    var backgroundColor: UIColor {
        switch self {
        case .inputValue, .inputFlow:
            return .systemPink
        case .outputValue, .outputFlow:
            return .systemPurple
        }
    }
}

class Outlet {
    var type: OutletType
    var inputVariable: VariableDefinition
    var view: UIView
    var connection: Connection?
    
    init(type: OutletType, inputVariable: VariableDefinition, view: UIView, connection: Connection? = nil) {
        self.type = type
        self.inputVariable = inputVariable
        self.view = view
        self.connection = connection
    }
    
    func clearConnection() {
        self.connection?.clear()
        self.connection = nil
    }
}
