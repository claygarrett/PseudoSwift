
// MARK: - Outlet
import UIKit
import PseudoSwift

enum OutletType: Int {
    case inputValue
    case outputValue
    case inputFlow
    case outputFlow
    
  
}

class Outlet {
    var type: OutletType
    var view: OutletView
    var connection: Connection?
    var value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, type: OutletType, connection: Connection? = nil, index: Int, frame: CGRect) {
        self.type = type
        self.connection = connection
        self.value = value
        
        view = OutletView(frame: frame, direction: Outlet.getDirectionFromOutletType(type: type), index: index, name: value.name)
    }
    
    func clearConnection() {
        self.connection?.clear()
        self.connection = nil
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
    }
    
    static func getDirectionFromOutletType(type: OutletType) -> VariableDirection {
        switch type {
        case .inputFlow, .inputValue:
            return .input
        case .outputFlow, .outputValue:
            return .output
        }
    }
}
