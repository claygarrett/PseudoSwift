
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
    private var title: String
    
    var type: OutletType {
        if self is ValueOutlet<ValueType> {
            return .value
        } else if self is FlowOutlet<ValueType> {
            return .flow
        } else {
            fatalError("Must use a subclass of Outlet")
        }
    }
    
    init(
        direction: OutletDirection,
        index: Int,
        frame: CGRect,
        title: String,
        container: Container
    ) {
        self.direction = direction
        self.container = container
        self.title = title
        
        view = OutletView(
            frame: frame,
            direction: direction,
            type: type,
            index: index,
            title: title
        )
    }
}

// TODO: Can this be combined with InputValue or share a super class for common bits?
class SetValueOutlet<ValueType>: ValueOutlet<ValueType> {
    
    public var wire: Wire<ValueType>?
    public func clearWire() {
        wire?.view.removeFromSuperview()
        wire = nil
    }
    init(
        value: Variable<ValueType>,
        index: Int,
        frame: CGRect,
        container: Container,
        title: String
    ) {
        super.init(
            value: value,
            direction: .input,
            index: index,
            frame: frame,
            container: container,
            title: title
        )
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
    init(
        value: Variable<ValueType>,
        index: Int,
        frame: CGRect,
        container: Container,
        title: String
    ) {
        super.init(
            value: value,
            direction: .input,
            index: index,
            frame: frame,
            container: container,
            title: title)
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
    
    init(
        value: Variable<ValueType>,
        index: Int,
        frame: CGRect,
        container: Container,
        title: String) {
        super.init(
            value: value,
            direction: .output,
            index: index,
            frame: frame,
            container: container,
            title: title
        )
    }
}

/// An outlet that passes or receives a value
class ValueOutlet<ValueType>: Outlet<ValueType> {
    
    var value: Variable<ValueType> {
        didSet {
            self.view.label.text = value.title
        }
    }

    init(
        value: Variable<ValueType>,
        direction: OutletDirection,
        index: Int,
        frame: CGRect,
        container: Container,
        title: String
    ) {
        self.value = value
        super.init(
            direction: direction,
            index: index,
            frame: frame,
            title: title,
            container: container
        )
    }
    
    func updateVariableName(name: String) {
        self.value.name = name
        self.view.label.text = name
    }
}

/// An outlet that passes or receives program flow
class FlowOutlet<ValueType>: Outlet<ValueType> {
    public var wire: Wire<ValueType>? = nil
    
    init(
        direction: OutletDirection,
        index: Int,
        frame: CGRect,
        container: Container
    ) {
        super.init(
            direction: direction,
            index: index,
            frame: frame,
            title: direction.titleForFlowOutlet(),
            container: container
        )
    }
    
    func clearWire() {
        wire?.view.removeFromSuperview()
        wire = nil
    }
}

extension OutletDirection {
    func titleForFlowOutlet() -> String {
        switch self {
        case .input:
            return "Flow Input"
        case .output:
            return "Flow Output"
        }
    }
}
