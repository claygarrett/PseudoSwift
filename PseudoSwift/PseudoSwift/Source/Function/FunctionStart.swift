//
//  FunctionStart.swift
//  PseudoSwift
//
//  Created by Clayton Garrett on 5/4/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import Foundation

class FunctionStart: FunctionStep {
    public var debugDescription: String = "Function Step: Function Start"
    
    var outputVariables: [VariablePlaceholder] {
        return []
    }
    
    var inputVariables: [VariablePlaceholder] {
        return []
    }
    
    func perform() throws {
        // nothing to do
        // this step is just a placeholder
        // so we know which step to startt on
    }
    
    func addVariableProvider<T>(provider: VariableProvider<T>) {
        
    }
    
    func requiredVariableProviders() -> [SupportedType] {
        return []
    }
}
