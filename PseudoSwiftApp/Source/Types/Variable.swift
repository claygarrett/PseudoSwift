

//protocol ValueGettable {
//    associatedtype T
//    func getValue() throws -> T
//}




class ValueSettable<VarType>: ValueGettable<VarType> {
    private var _value: VarType
    
    override func getValue() throws -> VarType {
        return _value
    }
    func setValue(_ value: VarType) {
        _value = value
    }
    
    override init(_ name: String, _ val: VarType) {
        self._value = val
        super.init(name: name)
    }
}

/// A holder of a value of a specific type that can be read from and written to
class ValueGettable<VarType> {
    func getValue() throws -> VarType {
        return try _valueProvider()
    }
    
    typealias T = VarType
    
    /// The name of this variable. Used for looking variables up when connecting
    /// FunctionSteps and Variables
    var name: String
        
    var _valueProvider: () throws ->VarType
    
    init(_ name: String, _ val: VarType) {
        self._valueProvider = { val }
        self.name = name
    }

    init(name: String) {
        self.name = name
        // variables initialized with this input are meant to
        // be temporary values that hold on to a type until they
        // are converted to a proper version that has a value provider.
        // so, calling them prior to that will result in a crash
        _valueProvider = { fatalError() }
    }
    
}

extension ValueGettable where VarType == Any {
    func equal<T>(val: T) -> ValueGettable<T> {
        return ValueGettable<T>(name, val)
    }
}

/// Global helper function to easily define a variable
/// The Variable returned by  this method will not have a value
/// but can be given one by following up the call with .equals(value)
func def(name: String) -> ValueGettable<Any> {
    let tempVariable: ValueGettable<Any> = ValueGettable(name: name)
    return tempVariable
}

class VariableProvider<T> {
    var values: [String: ValueGettable<T>]
    
    func getReadable(name: String) -> ValueGettable<T> {
        return values[name]!
    }
    
    func getWritable(name: String) -> ValueSettable<T> {
        return values[name]! as! ValueSettable<T>
    }
    
    init(values: [String: ValueGettable<T>]) {
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
    func toggle() -> BoolFlip {
        return BoolFlip(self)
    }
}

extension String {
    func set(_ partial: BoolAndPartial) -> BoolAnd {
        return BoolAnd(varToSet: self, leftVar: partial.leftVar, rightVar: partial.rightVar)
    }
}
