
//public typealias Var = ValueSettable
//public typealias Let = ValueGettable

public typealias ValueFollowCancellation<VarType> = (ValueSettable<VarType>) -> ()

public class ValueSettable<VarType>: ValueGettable<VarType> {

    
    var followerValues: [ValueSettable<VarType>] = []
    var followCancellation: ValueFollowCancellation<VarType>? = nil
    var isFollowing: Bool = false
    
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
    
    internal func setCancelation(cancellation: @escaping ValueFollowCancellation<VarType>) {
        self.followCancellation = cancellation
    }
    
    public func follow(follower: ValueSettable<VarType>) {
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

/// A holder of a value of a specific type that can be read from and written to
public class ValueGettable<VarType>: Hashable {
    public static func == (lhs: ValueGettable<VarType>, rhs: ValueGettable<VarType>) -> Bool {
        return lhs.name == rhs.name
    }
    
    typealias T = VarType
    
    /// The name of this variable. Used for looking variables up when connecting
    /// FunctionSteps and Variables
    public var name: String
    var initializer: () -> VarType
    
    var _valueProvider: () throws ->VarType
    
    public init(_ name: String, _ val: VarType) {
        self.initializer = { val }
        self._valueProvider = { val }
        self.name = name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    public init(name: String) {
        self.name = name
        // variables initialized with this input are meant to
        // be temporary values that hold on to a type until they
        // are converted to a proper version that has a value provider.
        // so, calling them prior to that will result in a crash
        _valueProvider = { 
            fatalError()
        }
        initializer = { fatalError() }
    }
    
    public func getValue() throws -> VarType {
        return try _valueProvider()
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

public class VariableProvider<T> {
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

public extension String {
    func toggle() -> BoolFlip {
        return BoolFlip(self)
    }
}

public extension String {
    func set(_ partial: BoolAndPartial) -> BoolAnd {
        return BoolAnd(varToSet: self, leftVar: partial.leftVar, rightVar: partial.rightVar)
    }
}

public class SetBoolEqualTo: FunctionStep {
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "SetBoolEqualTo")
        }
        let varToSet = boolProvider.getWritable(name: varToSetName)
        guard let varWithValueName = varWithValueName else {
            throw VariableError.VariableNameNotProvided(variable: "SetBoolEqualTo:varWithValueName")
        }
        let varWithValue = boolProvider.getReadable(name: varWithValueName)
        guard let value = try? varWithValue.getValue() else {
            fatalError("No value found for variable")
        }
        varToSet.setValue(value)
    }
    
    public init(varToSetName: String, varWithValueName: String? = nil) {
        self.varToSetName = varToSetName
        self.varWithValueName = varWithValueName
    }

    public var varToSetName: String
    public var varWithValueName: String?
    public var boolProvider: VariableProvider<Bool>? = nil
    
    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public var inputVariables: [VariableDefinition] {
        return [VariableDefinition(name: "leftVar", type: .boolean, direction: .input)]
    }
    
    public var outputVariables: [VariableDefinition] {
        return [VariableDefinition(name: "rightVar", type: .boolean, direction: .input)]
    }
    
    
}
