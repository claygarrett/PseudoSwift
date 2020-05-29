//
//import Foundation
//import PseudoSwift
//
//struct FlowNode {
//    
//}
//
//struct FlowManager {
//    var rootNode: SetVariableContainer<Bool>
//    init(rootNode: SetVariableContainer<Bool>) {
//        self.rootNode = rootNode
//    }
//    
//    func buildFunction() { //}-> Function<Bool> {
//        var currentContainer: SetVariableContainer? = rootNode
//        while currentContainer != nil {
//            currentContainer = traverseFlowContainer(container: currentContainer!)
//        }
//        
//    }
//    
//    func traverseFlowContainer(container: SetVariableContainer<Bool>) -> SetVariableContainer<Bool> {
//        // build the dependency graph to set the value of this node properly
//        for wire in container.valueOutlet.wires {
//            guard let provider = wire.sourceOutlet?.container as? FunctionContainer else {
//                continue
//            }
//            traverseFunctionContainer(container: provider)
//        }
//        
//        
//        return container.nextContainer as! SetVariableContainer<Bool>
//    }
//    
//    func traverseFunctionContainer(container: FunctionContainer<Bool>)  {
//        for wire in container.boolValueInputOutlets {
//            
//        }.wires {
//            guard let provider = wire.sourceOutlet?.container as? FunctionContainer else {
//                continue
//            }
//            var currentProvider: FunctionContainer? = provider
//            while currentProvider != nil {
//                // valueOutlet is an destinationOutlet outlet, so we want the source outlet of all
//                // wires connected to it
//                let sourceOutlet = wire.sourceOutlet
//                guard let container = sourceOutlet.container else {
//                    continue
//                }
//                currentProvider = traverseFunctionContainer(container: currentProvider)
//            }
//            
//            // make sure this container
//        }
//        
//    }
//}
