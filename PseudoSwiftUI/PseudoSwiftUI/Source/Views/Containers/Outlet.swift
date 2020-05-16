
// MARK: - Outlet
import UIKit
import PseudoSwift

enum OutletType: Int {
    case inputValue
    case outputValue
    case inputFlow
    case outputFlow
    
    var wireType: WireType {
        switch self {
        case .inputFlow, .outputFlow:
            return .flowWire
        case .inputValue, .outputValue:
            return .valueWire
        }
    }
}

class Outlet {
    var type: OutletType
    var view: OutletView
    var connections: [Connection]
    
    init(type: OutletType, connection: Connection? = nil, index: Int, frame: CGRect, name: String?) {
        self.type = type
        self.connections = connection == nil ? [] : [connection!]
        
        view = OutletView(frame: frame, type: type, index: index, name: name)
        print(self.view.frame)
    }

    func clearConnections() {
        connections.forEach { connection in
            connection.clear()
        }
        
        self.connections = []
    }
    
    func addConnection(connection: Connection) {
        connections.append(connection)
    }
    
    func hasConnection(connection: Connection) -> Bool {
        return connections.contains(where: { $0 === connection })
    }
    
    func clearIncomingConnections() {
        let incomingConnections = connections.filter { $0.destintationOutlet === self }
        for connection in incomingConnections {
            connection.clear()
        }
        connections.removeAll { (connection) -> Bool in
            incomingConnections.contains(where: { connection === $0 })
        }
        
        self.connections = []
    }
    
    static func getDirectionFromOutletType(type: OutletType) -> VariableDirection {
        switch type {
        case .inputFlow, .inputValue:
            return .input
        case .outputFlow, .outputValue:
            return .output
        }
    }
    
    var wireType: WireType {
        return type.wireType
    }
}

class ValueOutlet: Outlet {
    
    var value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, type: OutletType, connection: Connection? = nil, index: Int, frame: CGRect) {
        self.value = value
        super.init(type: type, index: index, frame: frame, name: value.name)
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
    }
}

class FlowOutlet: Outlet {
    init(type: OutletType, connection: Connection? = nil, index: Int, frame: CGRect) {
        super.init(type: type, index: index, frame: frame, name: nil)
    }
}
