
/// A holder of a value of a specific type that can be read from and written to
class Variable<VarType> {
    
    /// The name of this variable. Used for looking variables up when connecting
    /// FunctionSteps and Variables
    var name: String
    
    /// The primitive value of this Variable
    var value: VarType!
    
    /// Flags if this is a variable that should be used as an output Variable
    var isOutput: Bool
    
    init(_ val: VarType, name: String, isOutput: Bool = false) {
        self.value = val
        self.name = name
        self.isOutput = isOutput
    }

    init(name: String, isOutput: Bool = false) {
        self.name = name
        self.isOutput = isOutput
    }
    
    /// Helper method that returns a variable but converts it to an output Variable
    /// - Returns: The Variable, modified as an output Variable
    func asOutput() -> Variable<VarType> {
        self.isOutput = true
        return self
    }
}

extension Variable where VarType == Any {
    func equal<T>(val: T) -> Variable<T> {
        return Variable<T>(val , name: self.name)
    }
}

/// Global helper function to easily define a variable
/// The Variable returned by  this method will not have a value
/// but can be given one by following up the call with .equals(value)
func def(name: String) -> Variable<Any> {
    let tempVariable: Variable<Any> = Variable(name: name)
    return tempVariable
}

class VariableProvider<T> {
    var values: [String: Variable<T>]
    func get(name: String) -> Variable<T> {
        return values[name]!
    }
    
    init(values: [String: Variable<T>]) {
        self.values = values
    }
    
    func type() -> T.Type {
        return T.self
    }
}

class NilVariable<VarType> {
    let name: String
    let type: VarType.Type
    init(name: String, type: VarType.Type) {
        self.name = name
        self.type = type
    }
    
}

extension String {
    func flipBool() -> BoolFlip {
        return BoolFlip(self)
    }
}

extension String {
    func set(_ partial: BoolAndPartial) -> BoolAnd {
        return BoolAnd(varToSet: self, leftVar: partial.leftVar, rightVar: partial.rightVar)
    }
}
