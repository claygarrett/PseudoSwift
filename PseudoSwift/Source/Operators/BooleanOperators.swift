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

/// Compares two booleans. Returns true if they are both true, but otherwise returns false.
class BoolAnd: InfixOperator {
    override func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    override func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionAnd")
        }
        let leftVar = boolProvider.get(name: leftVarName)
        let rightVar = boolProvider.get(name: rightVarName)
        let varToSet = boolProvider.get(name: varToSetName)
        
        varToSet.value = rightVar.value && leftVar.value
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
        let leftVar = boolProvider.get(name: leftVarName)
        let rightVar = boolProvider.get(name: rightVarName)
        let varToSet = boolProvider.get(name: varToSetName)
        
        varToSet.value = rightVar.value || leftVar.value
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
        let targetVar = boolProvider.get(name: targetName)
        targetVar.value = !targetVar.value
    }
}

/// Performs branching. Takes a condition and performs one set of FunctionSteps if the
/// condition is true and a different set if it is false.
class If: FunctionStep {
    var boolProvider: VariableProvider<Bool>?
    let condition: () -> Bool
    let trueSteps: [FunctionStep]
    let falseSteps: [FunctionStep]
    
    init(
         _ condition:@escaping @autoclosure () -> Bool,
         Then  trueSteps: [FunctionStep],
         Else falseSteps: [FunctionStep]) {
        
        self.trueSteps = trueSteps
        self.falseSteps = falseSteps
        self.condition = condition
    }
    
    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
    func perform() throws {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "BooleanFunctionFlip")
        }
        
        let stepsToRun = condition() ? trueSteps : falseSteps
        
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
