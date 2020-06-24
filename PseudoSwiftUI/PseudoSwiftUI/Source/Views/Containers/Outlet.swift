
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

// TODO: Can this be combined with InputValue or share a super class for common bits?
class SetValueOutlet<ValueType>: ValueOutlet<ValueType> {
    
    public var wire: Wire<ValueType>?
    public func clearWire() {
        wire?.view.removeFromSuperview()
        wire = nil
    }
    init(value: Variable<ValueType>, index: Int, frame: CGRect, container: Container) {
        super.init(value: value, direction: .input, index: index, frame: frame, container: container)
    }
    
    public var sourceOutlet: OutputValueOutlet<ValueType>? {
        return wire?.sourceOutlet as? OutputValueOutlet<ValueType>
    }
    
    public var valueProviderContainer: ValueProviderContainer? {
        return sourceOutlet?.container as? ValueProviderContainer
    }
    
}

class InputValueOutlet<ValueType>: ValueOutlet<ValueType> {
    public var wire: Wire<ValueType>?
    public func clearWire() {
        wire?.view.removeFromSuperview()
        wire = nil
    }
    init(value: Variable<ValueType>, index: Int, frame: CGRect, container: Container) {
        super.init(value: value, direction: .input, index: index, frame: frame, container: container)
    }
    
    public var sourceOutlet: OutputValueOutlet<ValueType>? {
        return wire?.sourceOutlet as? OutputValueOutlet<ValueType>
    }
    
    public var valueProviderContainer: ValueProviderContainer? {
        return sourceOutlet?.container as? ValueProviderContainer
    }
    
}

class OutputValueOutlet<ValueType>: ValueOutlet<ValueType> {
    public var wires: [Wire<ValueType>] = []
    public var destinationOutlets: [InputValueOutlet<ValueType>] {
        return wires.compactMap { $0.destinationOutlet as? InputValueOutlet<ValueType> }
    }
    
    func clearWires() {
         wires.forEach { wire in
             wire.view.removeFromSuperview()
         }
         
         self.wires = []
     }
    
    func clearWire(_ wire: Wire<ValueType>) {
        wire.view.removeFromSuperview()
         
        self.wires.removeAll { otherWire -> Bool in
            wire === otherWire
        }
     }
    
    func addWire(wire: Wire<ValueType>) {
          wires.append(wire)
      }
    
    init(value: Variable<ValueType>, index: Int, frame: CGRect, container: Container) {
        super.init(value: value, direction: .output, index: index, frame: frame, container: container)
    }
}

class ValueOutlet<ValueType>: Outlet<ValueType> {
    
    var value: Variable<ValueType>

    init(value: Variable<ValueType>, direction: OutletDirection, index: Int, frame: CGRect, container: Container) {
        self.value = value
        super.init(direction: direction, index: index, frame: frame, name: value.name, container: container)
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
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
