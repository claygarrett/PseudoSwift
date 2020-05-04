/// Abstract superclass for any FunctionSteps that present as an operation between two variables
public class InfixOperator: FunctionStep {
    public var outputVariables: [VariableDefinition] {
        return [VariableDefinition(name: varToSetName, type: .boolean, direction: .output)]

    }
    
    public var inputVariables: [VariableDefinition] {
        return [
            VariableDefinition(name: leftVarName, type: .boolean, direction: .input),
            VariableDefinition(name: rightVarName, type: .boolean, direction: .input)
        ]
    }
    
    var leftVarName: String
    var rightVarName: String
    var varToSetName: String
    var boolProvider: VariableProvider<Bool>?

    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        fatalError("Must Override")
    }
    
    public init(varToSet: String, leftVar: String, rightVar: String) {
        self.varToSetName = varToSet
        self.leftVarName = leftVar
        self.rightVarName = rightVar
    }
    
    public func perform() throws {
        fatalError("Must Override")
    }
}

/// Abstract superclass for any FunctionSteps that present as an operation between two variables
public class SetBool: FunctionStep {
    public var outputVariables: [VariableDefinition] {
        return [
            VariableDefinition(name: varToSetName, type: .boolean, direction: .output)
        ]
    }
    
    public var inputVariables: [VariableDefinition] {
        return [
        ]
    }
    
    
    var boolProvider: VariableProvider<Bool>?
    
    var varToSetName: String
    let valToSet: Bool

    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
           self.boolProvider = provider as? VariableProvider<Bool>
       }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
          return [.boolean]
    }
  
    
    public init(varToSet: String, value: Bool) {
        self.varToSetName = varToSet
        self.valToSet = value
    }
    
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "SetVar")
        }
        let boolVariable = boolProvider.getWritable(name: varToSetName)
        boolVariable.setValue(valToSet)
    }
}


/// Compares two booleans. Returns true if they are both true, but otherwise returns false.
public class BoolAnd: InfixOperator {
    public override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public override func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionAnd")
        }
        let leftVar = boolProvider.getReadable(name: leftVarName)
        let rightVar = boolProvider.getReadable(name: rightVarName)
        
        let boolVariable = boolProvider.getWritable(name: varToSetName)
        try boolVariable.setValue(rightVar.getValue() && leftVar.getValue())
    }
}

/// Compares two booleans. Returns true if they are both true, but otherwise returns false.
public class BoolOr: InfixOperator {
    public override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public override func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionAnd")
        }
        let leftVar = boolProvider.getReadable(name: leftVarName)
        let rightVar = boolProvider.getReadable(name: rightVarName)
        let boolVariable = boolProvider.getWritable(name: varToSetName)
        try boolVariable.setValue(rightVar.getValue() || leftVar.getValue())
    }
}

/// Changes a boolean's value to the other possible option.
/// Changes true to false or false to true.
public class BoolFlip: FunctionStep {
    public var outputVariables: [VariableDefinition] {
        return [
            VariableDefinition(name: targetName, type: .boolean, direction: .output)
        ]
    }
    
    public var inputVariables: [VariableDefinition] {
        return [
            VariableDefinition(name: targetName, type: .boolean, direction: .input)
        ]
    }
    
    var targetName: String
    var boolProvider: VariableProvider<Bool>?
    
    
    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public init(_ targetName: String) {
        self.targetName = targetName
    }
    
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionFlip")
        }
        let targetVar = boolProvider.getWritable(name: targetName)
        try targetVar.setValue(!targetVar.getValue())
    }
}

/// Performs branching. Takes a condition and performs one set of FunctionSteps if the
/// condition is true and a different set if it is false.
public class If: FunctionStep {
    public var outputVariables: [VariableDefinition] {
        return []
    }
    
    public var inputVariables: [VariableDefinition] {
        return [
            VariableDefinition(name: "conditionalBool", type: .boolean, direction: .input),
            VariableDefinition(name: "trueSteps", type: .array(type: .functionStep), direction: .input),
            VariableDefinition(name: "falseSteps", type: .array(type: .functionStep), direction: .input)
        ]
    }
    
    var boolProvider: VariableProvider<Bool>?
    let trueSteps: [FunctionStep]
    let falseSteps: [FunctionStep]
    let conditionEvaluator: BoolEvaluator
    
  
    public init(
        _ conditionBool: String,
         Then  trueSteps: [FunctionStep],
         Else falseSteps: [FunctionStep] = []) {
        
        self.trueSteps = trueSteps
        self.falseSteps = falseSteps
        self.conditionEvaluator = BoolEvaluator(conditionBool)
    }
    
    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            boolProvider = provider as? VariableProvider<Bool>
            conditionEvaluator.addVariableProvider(provider: provider)
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionFlip")
        }
        
        
        guard let stepsToRun = try? conditionEvaluator.perform() ? trueSteps : falseSteps else {
            return
        }
      
        
        
        stepsToRun.forEach { step in
            step.requiredVariableProviders().forEach {
                switch $0 {
                case .boolean:
                    step.addVariableProvider(provider: boolProvider)
                case .functionStep:
                    fatalError("Implement me")
                case .array(type: let type):
                    fatalError("Implement me")
                }
            }
            
            do {
                try step.perform()
            } catch VariableError.VariableProviderNotFound(let source) {
                fatalError("\(source) was not given a variable provider.")
            } catch {
                fatalError("Unknown error")
            }
        }
        
    }
}
