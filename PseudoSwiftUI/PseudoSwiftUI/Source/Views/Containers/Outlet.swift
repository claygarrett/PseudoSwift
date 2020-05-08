
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
    var variable: VariableDefinition
    var view: OutletView
    var connection: Connection?
    
    init(type: OutletType, inputVariable: VariableDefinition, connection: Connection? = nil, index: Int, frame: CGRect) {
        self.type = type
        self.variable = inputVariable
        self.connection = connection
        
        view = OutletView(frame: frame, direction: variable.direction, index: index, name: inputVariable.name)
        
              
    }
    
    func clearConnection() {
        self.connection?.clear()
        self.connection = nil
    }
}
