
// MARK: - Outlet
import UIKit
import PseudoSwift

public enum OutletDirection: Int {
    case input
    case output
}

public enum OutletType: Int {
    case value
    case flow
}

public class Outlet<ValueType> {
    public var direction: OutletDirection
    public var view: OutletView!
    public weak var container: Container? = nil
    
    var type: OutletType {
        if self is ValueOutlet<ValueType> {
            return .value
        } else if self is FlowOutlet<ValueType> {
            return .flow
        } else {
            fatalError("Must use a subclass of Outlet")
        }
    }
    
    init(direction: OutletDirection, index: Int, frame: CGRect, name: String?, container: Container) {
        self.direction = direction
        self.container = container
        
        view = OutletView(frame: frame, direction: direction, type: type, index: index, name: name)
        print(self.view.frame)
    }

    
}

class ValueOutlet<ValueType>: Outlet<ValueType> {
    
    var value: ValueSettable<ValueType>
    public var wires: [Wire<ValueType>] = []

    init(value: ValueSettable<ValueType>, direction: OutletDirection, index: Int, frame: CGRect, container: Container) {
        self.value = value
        super.init(direction: direction, index: index, frame: frame, name: value.name, container: container)
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
    }
    
    func clearWires() {
        wires.forEach { wire in
            wire.view.removeFromSuperview()
        }
        
        self.wires = []
    }
    
    func addWire(wire: Wire<ValueType>) {
        wires.append(wire)
    }
    
    func clearIncomingWires() {
        let incomingWires = wires.filter { $0.destinationOutlet === self }
        for wire in incomingWires {
            wire.view.removeFromSuperview()
        }
        wires.removeAll { (wire) -> Bool in
            incomingWires.contains(where: { wire === $0 })
        }
        
        self.wires = []
    }
}

class FlowOutlet<ValueType>: Outlet<ValueType> {
    public var wire: Wire<ValueType>? = nil
    
    init(direction: OutletDirection, index: Int, frame: CGRect, container: Container) {
        super.init(direction: direction, index: index, frame: frame, name: nil, container: container)
    }
    
    func clearWire() {
        wire?.view.removeFromSuperview()
        wire = nil
    }
    

}
