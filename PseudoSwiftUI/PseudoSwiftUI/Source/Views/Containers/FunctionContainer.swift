

import UIKit
import PseudoSwift

final class FunctionContainer: Container {
    
    let nameLabel: UILabel = UILabel()
    let inputs: [VariableDefinition]
    let output: VariableDefinition?

    
    init(positionPercentage: CGPoint, inputs: [VariableDefinition] = [], output: VariableDefinition? = nil, variables: [VariableDefinition] = [], name: String) {
        self.inputs = inputs
        self.output = output
        super.init(positionPercentage: positionPercentage, name: name)
        
    }
    
    override func viewDidLoad() {
        for (index, input) in inputs.enumerated() {
            let inputOutlet = Outlet(type: .inputValue, inputVariable: input, index: index, frame: self.view.frame)
            outlets.append(inputOutlet)
        }
        
        if let output = output {
            let outputOutlet = Outlet(type: .outputValue, inputVariable: output, index: 0, frame: self.view.frame)
            outlets.append(outputOutlet)
        }
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        nameLabel.text = name
        nameLabel.frame = CGRect(x: 10, y: 10, width: 120, height: 20)
        nameLabel.textColor = .white
        self.view.addSubview(nameLabel)
    }
    

}
