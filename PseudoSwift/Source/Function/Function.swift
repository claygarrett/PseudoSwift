import Foundation

/// Accepts a list of variables and a list of FunctionSteps that act on those variables.
/// Provides the glue between the defined variables and the function steps that need them.
/// Variables have String names and function steps define the variables they act on
/// by referencing these names.

/// If a given Variable does not match the type that a given FunctionStep expects, we will
/// throw an error.

/// You build a function by passing into its instantiator a list of variables and steps.
/// We use function builders to build the array of steps and variables. This allows you to
/// call build functions  in a way that should feel similar to normal Swfit functions:
///
/// ```
/// let flipBoolFunc = Function<Bool> {
///    def(name: "canFlip").equal(val: true).asOutput()
///    def(name: "isFlipped").equal(val: false)
///    FlipBool("isFlipped")
///    AndBool(def: "isFlipped", left: "isFlipped", right: "canFlip")
/// }
/// ```
///
/// It's up to you to ensure you pass the correct types of elements to the function. If we find items
/// of types that we don't expect passed into the function builder, we will throw.
struct Function<Output> {
    
    /// The steps that make up the function. They are not directly dependent on each other
    /// but have a loosely-typed dependency on the provided variables. There should be
    /// a variable of matching name and type provided for each variable that exists in our steps.
    let steps: [FunctionStep]
    
    /// The name of the variable that should be returned after performing all of our steps
    var outputVariableName: String!
    
    /// All boolean variables. We split all provided variables into maps by type.
    var booleanVariables: [String: Variable<Bool>] = [:]
    
    /// All providers of boolean variables. Just a simplified wrapper for our map of variables
    var booleanVariableProvider: VariableProvider<Bool>
    
    init(@FunctionVariablesBuilder _ lines: ()->[AnyObject]) {
        
        let allLines = lines()
        
        // Break out each variable from our lines
        let variables = allLines.compactMap { (line) -> Any? in
            return line is Variable<Bool> ? line : nil
        }
        
        // Break out each step from our lines
        self.steps = allLines.compactMap { (line) -> FunctionStep? in
            guard let step = line as? FunctionStep else {
                return nil
            }
            return step
        }
        
        // Split our variables by type
        for variable in variables {
            switch variable {
            case let booleanVar as Variable<Bool>:
                self.booleanVariables[booleanVar.name] = booleanVar
                if booleanVar.isOutput {
                    self.outputVariableName = booleanVar.name
                }
            default:
                fatalError("Sent in an unexpected variable type")
            }
        }
        
        // find output step
        guard let outputStep = allLines.compactMap({ (line: Any) -> (FunctionOutput?) in
            switch line {
            case let output as FunctionOutput:
                return output
            default:
                return nil
            }
        }).first else {
            fatalError("Function did not have an output step")
        }
        
        
        
        // Wrap our variables in providers
        booleanVariableProvider = VariableProvider(values: self.booleanVariables)
        
        outputVariableName = outputStep.name
        
        guard outputVariableName.count > 0 else {
            fatalError("No output variable supplied")
        }
    }
    
    /// Enables our Function type to be callable. For instance:
    /// ```
    /// let someFunc = Function {
    /// // some steps
    /// }
    /// someFunc() // enabled by callAsFunction
    /// ```
    func callAsFunction() throws -> Output {
        for step in steps {
            // Hook up all the variable providers that this step needs
            step.requiredVariableProviders().forEach {
                switch $0 {
                case .boolean:
                    step.addVariableProvider(provider: booleanVariableProvider)
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
        
        // Get the value for our final output and return it
        if booleanVariableProvider.values.first!.value.value is Output {
            return booleanVariableProvider.get(name: outputVariableName).value as! Output
        }
        
        fatalError("Output variable name was missing or of incorrect type")
    }
}

/// Our function builder that takes a row of lines and wraps them into an array that we parse
@_functionBuilder
class FunctionVariablesBuilder {
    static func buildBlock(_ steps: AnyObject...) -> [AnyObject] {
        return steps
    }
}
