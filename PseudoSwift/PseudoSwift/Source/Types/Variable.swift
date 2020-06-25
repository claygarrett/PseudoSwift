
//public typealias Var = Variable
//public typealias Let = Variable

public typealias VariableFollowCancellation<VarType> = (Variable<VarType>) -> ()

public class Variable<VarType>: CustomDebugStringConvertible {
    
    typealias T = VarType
      
    /// The name of this variable. Used for looking variables up when connecting
    /// FunctionSteps and Variables
    public var name: String
    private var _title: String? = nil
    var initializer: () -> VarType
    var _valueProvider: () throws ->VarType
    var followerValues: [Variable<VarType>] = []
    var followCancellation: VariableFollowCancellation<VarType>? = nil
    
    
    public var debugDescription: String {
        var description = "Variable<\(T.self)>\n"
        description += "Name: \(name)\n"
        description += "Title: \(_title ?? "")\n"
        // you can have a blank initalizer but calling it will fatal error
//        description += "Initializer: \(self.initializer())\n"
        if let value = try?_valueProvider() {
            description += "Value Provider: \(value)\n"
        } else {
            description += "Value Provider: Threw Error!"
        }
        description += "Follower Values: \(followerValues)\n"
        description += "Follower Cancellation?: \(followCancellation != nil)\n"

        return description
    }
    
    public init(_ name: String, _ val: VarType, title: String? = nil) {
        _title = title
        initializer = { val }
        _valueProvider = { val }
        self.name = name
    }
    
    public static func == (lhs: Variable<VarType>, rhs: Variable<VarType>) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public init(name: String, title: String? = nil) {
        self.name = name
        // variables initialized with this input are meant to
        // be temporary values that hold on to a type until they
        // are converted to a proper version that has a value provider.
        // so, calling them prior to that will result in a crash
        _valueProvider = {
            fatalError()
        }
        
        initializer = { 
            print("Name: \(name) Title: \(String(describing: title))")
            fatalError()
        }
    }
    
    public func getValue() throws -> VarType {
        return try _valueProvider()
    }
    
    public var title: String {
        return _title ?? name
    }
    
    func leaderValueChanged(value: VarType) {
        _valueProvider = { value }
    }
    
    public func setValue(_ value: VarType) {
        setValueProvider({ value })
    }
    
    internal func setValueProvider(_ valueProvider: @escaping () throws -> VarType) {
        _valueProvider = valueProvider
        pipeToFollowers()
    }
    
    public func stopFollowing() {
        followCancellation?(self)
        followCancellation = nil
    }
    
    private func pipeToFollowers() {
        for followerValue in followerValues {
            followerValue.setValueProvider(self._valueProvider)
        }
    }
    
    internal func setCancelation(cancellation: @escaping VariableFollowCancellation<VarType>) {
        self.followCancellation = cancellation
    }
    
    public func follow(follower: Variable<VarType>) {
        if !followerValues.contains(where: { $0 === follower}) {
            followerValues.append(follower)
        }
        follower.followCancellation = { [unowned self] cancel in
            self.followerValues.removeAll(where: { $0 === cancel })
        }
    }
    
    public func reset() {
        if followCancellation != nil {
            // don't reset values that are followers of other variables
            return
        }
        setValueProvider(initializer)
    }
    
    public func setDefaultValue(_ value: VarType) {
        initializer = { value }
        reset()
    }
}


extension Variable where VarType == Any {
    func equal<T>(val: T) -> Variable<T> {
        return Variable<T>(name, val)
    }
}

/// Global helper function to easily define a variable
/// The Variable returned by  this method will not have a value
/// but can be given one by following up the call with .equals(value)
func def(name: String) -> Variable<Any> {
    let tempVariable: Variable<Any> = Variable(name: name)
    return tempVariable
}

public class VariableProvider<T> {
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

public extension String {
    func set(_ partial: BoolAndPartial) -> BoolAnd {
        return BoolAnd(varToSet: self, leftVar: partial.leftVar, rightVar: partial.rightVar)
    }
}

public class SetBoolEqualTo: FunctionStep {
    
    public var varToSetName: String
    public var varWithValueName: String?
    public var boolProvider: VariableProvider<Bool>? = nil
    
    public var debugDescription: String {
        var description = "Function Step: Set Bool Equal To\n"
        description += "Var to Set Name: \(varToSetName)\n"
        description += "Var with Value Name: \(varWithValueName ?? "")\n"
        description += "Bool Provider: \(String(describing: boolProvider))\n"
        return description
    }
    
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "SetBoolEqualTo")
        }
        let varToSet = boolProvider.get(name: varToSetName)
        guard let varWithValueName = varWithValueName else {
            throw VariableError.VariableNameNotProvided(variable: "SetBoolEqualTo:varWithValueName")
        }
        let varWithValue = boolProvider.get(name: varWithValueName)
        guard let value = try? varWithValue.getValue() else {
            fatalError("No value found for variable")
        }
        varToSet.setValue(value)
    }
    
    public init(varToSetName: String, varWithValueName: String? = nil) {
        self.varToSetName = varToSetName
        self.varWithValueName = varWithValueName
    }
    
    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public var inputVariables: [VariablePlaceholder] {
        return [VariablePlaceholder(name: "leftVar", type: .boolean, direction: .input)]
    }
    
    public var outputVariables: [VariablePlaceholder] {
        return [VariablePlaceholder(name: "rightVar", type: .boolean, direction: .input)]
    }
    
    
}
