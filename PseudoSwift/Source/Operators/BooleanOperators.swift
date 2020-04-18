/// Abstract superclass for any FunctionSteps that present as an operation between two variables
class InfixOperator: FunctionStep {
    var leftVarName: String
    var rightVarName: String
    var varToSetName: String
    var boolProvider: VariableProvider<Bool>?

    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        fatalError("Must Override")
    }
    
    init(varToSet: String, leftVar: String, rightVar: String) {
        self.varToSetName = varToSet
        self.leftVarName = leftVar
        self.rightVarName = rightVar
    }
    
    func perform() throws {
        fatalError("Must Override")
    }
}

/// Abstract superclass for any FunctionSteps that present as an operation between two variables
class SetBool: FunctionStep {
    
    var boolProvider: VariableProvider<Bool>?
    
    var varToSetName: String
    let valToSet: Bool

    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
           self.boolProvider = provider as? VariableProvider<Bool>
       }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
          return [.boolean]
    }
  
    
    init(varToSet: String, value: Bool) {
        self.varToSetName = varToSet
        self.valToSet = value
    }
    
    func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "SetVar")
        }
        let boolVariable = boolProvider.getWritable(name: varToSetName)
        boolVariable.setValue(valToSet)
    }
}


/// Compares two booleans. Returns true if they are both true, but otherwise returns false.
class BoolAnd: InfixOperator {
    override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    override func perform() throws {
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
class BoolOr: InfixOperator {
    override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    override func perform() throws {
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
class BoolFlip: FunctionStep {
    var targetName: String
    var boolProvider: VariableProvider<Bool>?
    
    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    init(_ targetName: String) {
        self.targetName = targetName
    }
    
    func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionFlip")
        }
        let targetVar = boolProvider.getWritable(name: targetName)
        try targetVar.setValue(!targetVar.getValue())
    }
}

/// Performs branching. Takes a condition and performs one set of FunctionSteps if the
/// condition is true and a different set if it is false.
class If: FunctionStep {
    var boolProvider: VariableProvider<Bool>?
    let trueSteps: [FunctionStep]
    let falseSteps: [FunctionStep]
    let conditionEvaluator: BoolEvaluator
    
  
    init(
        _ conditionBool: String,
         Then  trueSteps: [FunctionStep],
         Else falseSteps: [FunctionStep] = []) {
        
        self.trueSteps = trueSteps
        self.falseSteps = falseSteps
        self.conditionEvaluator = BoolEvaluator(conditionBool)
    }
    
    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            boolProvider = provider as? VariableProvider<Bool>
            conditionEvaluator.addVariableProvider(provider: provider)
        }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    func perform() throws {
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
