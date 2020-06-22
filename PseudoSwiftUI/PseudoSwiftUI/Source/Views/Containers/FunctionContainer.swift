

import UIKit
import PseudoSwift

class ValueProviderContainer: Container {
    var output: ValueSettable<Bool>
    
    init(positionPercentage: CGPoint, output: ValueSettable<Bool>, name: String, isFlowConductor: Bool) {
        self.output = output
        super.init(positionPercentage: positionPercentage, name: name, isFlowConductor: isFlowConductor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FunctionStepContainer: ValueProviderContainer {
    
    let nameLabel: UILabel = UILabel()
    let inputs: [ValueSettable<Bool>]
    let functionStep: FunctionStep
    
    init(functionStep: FunctionStep, positionPercentage: CGPoint, inputs: [ValueSettable<Bool>] = [], output: ValueSettable<Bool>, variables: [ValueSettable<Bool>] = [], name: String) {
        self.inputs = inputs
        self.functionStep = functionStep
        super.init(positionPercentage: positionPercentage, output: output, name: name, isFlowConductor: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        for (index, input) in inputs.enumerated() {
            let inputOutlet = InputValueOutlet(value: input, index: index, frame: self.view.frame, container: self)
            boolOutlets.append(inputOutlet)
        }
        
            let outputOutlet = OutputValueOutlet(value: output, index: 0, frame: self.view.frame, container: self)
            boolOutlets.append(outputOutlet)
        
        super.viewDidLoad()
    }
    

    override func draw() {
        nameLabel.text = name
        nameLabel.frame = CGRect(x: 10, y: 10, width: 120, height: 20)
        nameLabel.textColor = .white
        self.view.addSubview(nameLabel)
    }
    

}
