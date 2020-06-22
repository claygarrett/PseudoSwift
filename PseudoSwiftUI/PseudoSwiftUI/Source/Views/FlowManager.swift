
import Foundation
import PseudoSwift

struct FlowNode {
    
}

struct FlowManager {
    var rootNode: FlowContainer
    init(rootNode: FlowContainer) {
        self.rootNode = rootNode
    }
    
    private var function = Function<Bool>(name: "Clay's Magical Function")
    
    mutating func buildFunction() -> Function<Bool> {
        function = Function<Bool>(name: "Clay's Magical Function")
        var currentContainer: FlowContainer? = rootNode
        while currentContainer != nil {
            currentContainer = traverseFlowNodes(container: currentContainer!)
        }
        function.addLine(FunctionOutput(name: "Clay"))
        return function
    }
    
    func traverseFlowNodes(container: FlowContainer) -> FlowContainer? {
        // build the dependency graph to set the value of this node properly
        
        if let setVariableContainer = container as? SetVariableContainer<Bool> {
            // TODO: Clay -- can this be a value provider rather than a function container to be more generic?
                   guard let provider = setVariableContainer.valueOutlet.wire?.sourceOutlet?.container as? ValueProviderContainer else {
                       fatalError("A value container for container \(setVariableContainer.value.name) was not connected to a Function Container")
                   }
            
            
                  traverseValueProviderChain(container: provider)
                  
                  // CLAY Here's where you left off
                  // we really only need to add the variable once
                  // but this will add it every time it's set
                  // probably ok for now
                  // variables that are defined but never set are
                  // useless and will never be added to the function
                  
                  // thought -- what if we start building the function in the workspace
                  // by adding the variables each time one is connected to another via a wire
                  // (since the order the variables are added in doesn't matter).
                  // then, add the steps in order at the end by calling the flow manager
                  // since the transfer of data from one function to another is done
                  // by "following" variables when the wires are created the only
                  // thing that needs to get added at the end is the
                  // function steps themselves.
                  // If we add variables to the functions as wires are connected
                  // we'd have to do some work to make it efficient (don't add them till they're "hot"
                  // and remove them when they go cold. That in itself probably makes it not worth it?
            
                  function.addLine(setVariableContainer.value)
                let setVarFunction = SetBoolEqualTo(varToSetName: setVariableContainer.valueOutlet.value.name, varWithValueName: setVariableContainer.valueOutlet.valueProviderContainer?.output.name)
                function.addLine(setVarFunction as AnyObject)
        } else if let setVariableContainer = container as? SetVariableContainer<Bool> {
            
        }
                
        return container.nextContainer
    }
    
    func traverseValueProviderChain(container: ValueProviderContainer) {
        
        if let defVariableContainer = container as? DefVariableContainer {
            function.addLine(defVariableContainer.output as AnyObject)
        }
        
        for inputOutlet in container.boolValueInputOutlets {
            guard let valueContainer = inputOutlet.valueProviderContainer else {
                fatalError("A value container for outlet \(inputOutlet.value.name) was not connected to a ValueProviderContainer")
            }
            traverseValueProviderChain(container: valueContainer)
        }
        
        
        
        if let functionStepContainer = container as? FunctionStepContainer {
            // TODO: Locally keep track of lines as to not double add inputs?
            // Even though this works fine -- they're deduped in the addLine function
            
            function.addLines(functionStepContainer.inputs)
            function.addLine(functionStepContainer.output)
            function.addLine(functionStepContainer.functionStep as AnyObject)
        }
    }
}
