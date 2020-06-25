
/// A list of all of the types our system knows about and can act on
/// If a type is not in this list, it cannot be used as part of a FunctionStep
public indirect enum SupportedType: Equatable {
    case boolean
    case functionStep
    case array(type: SupportedType)
}

public class VariablePlaceholder: CustomDebugStringConvertible {
    public var debugDescription: String {
        var description = "Variable Placeholder"
        description += "Name: \(name)\n"
        description += "Type: \(type)\n"
        description += "Direction: \(direction)\n"
        return description
    }
    
    public var name: String
    public let type: SupportedType
    public let direction: VariableDirection
    
    public init(name: String, type: SupportedType, direction: VariableDirection) {
        self.name = name
        self.type = type
        self.direction = direction
    }
}

public enum VariableDirection {
    case input
    case output
}


