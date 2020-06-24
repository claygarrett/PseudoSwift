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
public class Function<Output>: ValueSettable<Output> {
    public override func getValue() throws -> Output {
        do { return try self() } catch { fatalError() }
    }
    
    typealias T = Output
    /// The steps that make up the function. They are not directly dependent on each other
    /// but have a loosely-typed dependency on the provided variables. There should be
    /// a variable of matching name and type provided for each variable that exists in our steps.
    var steps: [FunctionStep]
    
    /// The name of the variable that should be returned after performing all of our steps
    var outputVariableName: String!
    
    /// All boolean variables. We split all provided variables into maps by type.
    var booleanVariables: [String: ValueSettable<Bool>] = [:]
    
    /// All providers of boolean variables. Just a simplified wrapper for our map of variables
    var booleanVariableProvider: VariableProvider<Bool>
    
    public override init(name: String = "") {
        self.steps = []
        self.booleanVariableProvider = VariableProvider<Bool>(values: [:])
        super.init(name: name)
    }
    
    public init(@FunctionVariablesBuilder _ lines: ()->[AnyObject], name: String = "") {
        
        let allLines = lines()
        
        // Break out each variable from our lines
        let variables = allLines.compactMap { (line) -> Any? in
            return line is ValueSettable<Bool> ? line : nil
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
            case let booleanVar as ValueSettable<Bool>:
                self.booleanVariables[booleanVar.name] = booleanVar
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
        
        super.init(name: name)
        self._valueProvider = { try self() }
    }
    
    public func addLines(_ lines: [AnyObject]) {
        for line in lines {
            addLine(line)
        }
    }
    
    public func addLine(_ line: AnyObject) {
        // Break out each variable from our lines
        if line is ValueSettable<Bool> {
            switch line {
            case let booleanVar as ValueSettable<Bool>:
                self.booleanVariables[booleanVar.name] = booleanVar
            default:
                fatalError("Sent in an unexpected variable type")
            }
        }
        
        if let step = line as? FunctionStep {
            self.steps.append(step)
        }
       
        if let outputStep = line as? FunctionOutput {
            outputVariableName = outputStep.name
        }
        
        // Wrap our variables in providers
        booleanVariableProvider = VariableProvider(values: self.booleanVariables)
    }

    /// Enables our Function type to be callable. For instance:
    /// ```
    /// let someFunc = Function {
    /// // some steps
    /// }
    /// someFunc() // enabled by callAsFunction
    /// ```
    public func callAsFunction() throws -> Output {
        for step in steps {
            // Hook up all the variable providers that this step needs
            step.requiredVariableProviders().forEach {
                switch $0 {
                case .boolean:
                    step.addVariableProvider(provider: booleanVariableProvider)
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
        
        // Get the value for our final output and return it
        
       return try booleanVariableProvider.getReadable(name: outputVariableName).getValue() as! Output
       
        
    }
}

/// Our function builder that takes a row of lines and wraps them into an array that we parse
@_functionBuilder
public class FunctionVariablesBuilder {
    public static func buildBlock(_ steps: AnyObject...) -> [AnyObject] {
        return steps
    }
}
