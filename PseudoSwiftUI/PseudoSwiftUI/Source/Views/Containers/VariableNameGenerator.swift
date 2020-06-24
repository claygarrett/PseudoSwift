
import Foundation

class VariableNameGenerator {
    var currentVariableNames: Set<String> = []
    var nextVariableName = "Variable 1"
    
    func registerExistingVariableName(_ name: String) {
        currentVariableNames.insert(name)
        generateNextVariableName()
    }
    
    func generateNextVariableName() {
        var numberVariablesTried = 0
        while currentVariableNames.contains(nextVariableName) {
            numberVariablesTried += 1
            nextVariableName = "Variable \(numberVariablesTried)"
        }
    }
    
    func getUniqueVariableName() -> String {
        generateNextVariableName()
        currentVariableNames.insert(nextVariableName)
        return nextVariableName
    }
}
