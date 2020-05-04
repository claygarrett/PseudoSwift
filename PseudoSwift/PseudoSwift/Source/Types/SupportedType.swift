
// A list of all of the types our system knows about and can act on
/// If a type is not in this list, it cannot be used as part of a FunctionStep
public indirect enum SupportedType: Equatable {
    case boolean
    case functionStep
    case array(type: SupportedType)
}

public struct VariableDefinition {
    let name: String
    let type: SupportedType
    let direction: VariableDirection
    
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


