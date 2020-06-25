/// Abstract superclass for any FunctionSteps that present as an operation between two variables
public class InfixOperator: FunctionStep {
    public var debugDescription: String {
        var description = "Infix Operator"
        description += "Input Variables: \(self.inputVariables)\n"
        description += "Output Variavbles: \(self.outputVariables)\n"
        description += "Left Var Naem: \(leftVarName)\n"
        description += "Right Var Naem: \(rightVarName)\n"
        description += "Right Var Naem: \(varToSetName)\n"
        description += "Bool Provider: \(String(describing: boolProvider))\n"
        
        return description
    }
    
    public var outputVariables: [VariablePlaceholder] {
        return [VariablePlaceholder(name: varToSetName, type: .boolean, direction: .output)]

    }
    
    public var inputVariables: [VariablePlaceholder] {
        return [
            VariablePlaceholder(name: leftVarName, type: .boolean, direction: .input),
            VariablePlaceholder(name: rightVarName, type: .boolean, direction: .input)
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

/// Compares two booleans. Returns true if they are both true, but otherwise returns false.
    public class BoolAnd: InfixOperator {
    public override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public override func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionAnd")
        }
        let leftVar = boolProvider.get(name: leftVarName)
        let rightVar = boolProvider.get(name: rightVarName)
        
        let boolVariable = boolProvider.get(name: varToSetName)
        let rightVarValue = try rightVar.getValue()
        let leftVarValue = try leftVar.getValue()
        boolVariable.setValue(leftVarValue && rightVarValue)
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
        let leftVar = boolProvider.get(name: leftVarName)
        let rightVar = boolProvider.get(name: rightVarName)
        let boolVariable = boolProvider.get(name: varToSetName)
        try boolVariable.setValue(rightVar.getValue() || leftVar.getValue())
    }
}

/// Changes a boolean's value to the other possible option.
/// Changes true to false or false to true.
public class BoolFlip: FunctionStep {
    public var debugDescription: String = "CLAY"
    
    public var outputVariables: [VariablePlaceholder] {
        return [
            VariablePlaceholder(name: destinationVariableName, type: .boolean, direction: .output)
        ]
    }
    
    public var inputVariables: [VariablePlaceholder] {
        return [
            VariablePlaceholder(name: sourceVariableName, type: .boolean, direction: .input)
        ]
    }
    
    var sourceVariableName: String
    var destinationVariableName: String
    var boolProvider: VariableProvider<Bool>?
    
    public func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    public func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    public init(sourceVariableName: String, destinationVariableName: String) {
        self.sourceVariableName = sourceVariableName
        self.destinationVariableName = destinationVariableName
    }
    
    public func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionFlip")
        }
        let sourceVar = boolProvider.get(name: sourceVariableName)
        let destinationVar = boolProvider.get(name: destinationVariableName)
        try destinationVar.setValue(!sourceVar.getValue())
    }
}

/// Performs branching. Takes a condition and performs one set of FunctionSteps if the
/// condition is true and a different set if it is false.
public class If: FunctionStep {
    public var debugDescription: String = "CLAY"
    
    public var outputVariables: [VariablePlaceholder] {
        return []
    }
    
    public var inputVariables: [VariablePlaceholder] {
        return [
            VariablePlaceholder(name: "conditionalBool", type: .boolean, direction: .input),
            VariablePlaceholder(name: "trueSteps", type: .array(type: .functionStep), direction: .input),
            VariablePlaceholder(name: "falseSteps", type: .array(type: .functionStep), direction: .input)
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
                case .array:
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
