
// MARK: - Outlet
import UIKit
import PseudoSwift

enum OutletDirection: Int {
    case input
    case output
}

enum OutletType: Int {
    case value
    case flow
}

class Outlet {
    var direction: OutletDirection
    var view: OutletView!
    var connections: [Connection]
    
    var type: OutletType {
        if self is ValueOutlet {
            return .value
        } else if self is FlowOutlet {
            return .flow
        } else {
            fatalError("Must use a subclass of Outlet")
        }
    }
    
    init(direction: OutletDirection, connection: Connection? = nil, index: Int, frame: CGRect, name: String?) {
        self.direction = direction
        self.connections = connection == nil ? [] : [connection!]
        
        view = OutletView(frame: frame, direction: direction, type: type, index: index, name: name)
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
    
}

class ValueOutlet: Outlet {
    
    var value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, direction: OutletDirection, connection: Connection? = nil, index: Int, frame: CGRect) {
        self.value = value
        super.init(direction: direction, index: index, frame: frame, name: value.name)
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
    }
    

}

class FlowOutlet: Outlet {
    init(direction: OutletDirection, connection: Connection? = nil, index: Int, frame: CGRect) {
        super.init(direction: direction, index: index, frame: frame, name: nil)
    }
}
