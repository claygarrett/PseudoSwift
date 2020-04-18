
import Foundation

/// An object that sets/transforms values based on predefined logic
/// Function steps can contain relatively simple functionality such as operators (+, -, *, &&, ||, etc)
/// Or can contain much more complex logic .
protocol FunctionStep {
    /// Do the logic contained in this step by reading from, transforming, and setting dependent variables.
    func perform() throws
    
    /// Add a Variable provider that we can use to look up our Variables by name when we need
    /// - Parameter provider: The provider we should use to look up Variables. You should
    /// only add variable providers of types returned when calling `requiredVariableProviders`
    func addVariableProvider<T>(provider: VariableProvider<T>)
    
    /// A collection of the types of Variables we are dependent on.
    func requiredVariableProviders() -> [SupportedType]
}

protocol ValueProducingFunctionStep {
    associatedtype ReturnValue
    func perform() throws -> ReturnValue
}

class BoolEvaluator: ValueProducingFunctionStep {
    
    let varName: String

    init(_ varName: String) {
        self.varName = varName
    }
    
    func perform() throws -> Bool {
        guard let boolProvider = self.boolProvider else {
            throw VariableError.VariableProviderNotFound(source: "Bool Evaluator")
        }
        
        return try boolProvider.getReadable(name: varName).getValue()
    }
    
    typealias ReturnValue = Bool
    
    var boolProvider: VariableProvider<Bool>?
     

    func addVariableProvider<T>(provider: VariableProvider<T>) {
        if provider.type().self == Bool.self {
            self.boolProvider = provider as? VariableProvider<Bool>
        }
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        return [.boolean]
    }
    
}

class True: ValueProducingFunctionStep {
    typealias ReturnValue = Bool
    func perform() throws -> Bool {
        return true
    }
}

class False: ValueProducingFunctionStep {
    typealias ReturnValue = Bool
    func perform() throws -> Bool {
        return false
    }
}

struct BoolAndPartial {
    let leftVar: String
    let rightVar: String
    init(leftVar: String, rightVar: String) {
        self.leftVar = leftVar
        self.rightVar = rightVar
    }
}

struct BoolOrPartial {
    let leftVar: String
    let rightVar: String
    init(leftVar: String, rightVar: String) {
        self.leftVar = leftVar
        self.rightVar = rightVar
    }
}

class FunctionOutput {
    var name: String
    init(name: String) {
        self.name = name
    }
}
