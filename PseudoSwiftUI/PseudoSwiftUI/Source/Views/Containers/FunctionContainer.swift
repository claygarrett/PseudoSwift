

import UIKit
import PseudoSwift

final class FunctionContainer: Container {
    
    let nameLabel: UILabel = UILabel()
    let inputs: [ValueSettable<Bool>]
    let output: ValueSettable<Bool>?
    

    
    init(positionPercentage: CGPoint, inputs: [ValueSettable<Bool>] = [], output: ValueSettable<Bool>? = nil, variables: [ValueSettable<Bool>] = [], name: String) {
        self.inputs = inputs
        self.output = output
        super.init(positionPercentage: positionPercentage, name: name, isFlowConductor: false)
        
    }
    
    override func viewDidLoad() {
        for (index, input) in inputs.enumerated() {
            let inputOutlet = ValueOutlet(value: input, direction: .input, index: index, frame: self.view.frame, container: self)
            boolOutlets.append(inputOutlet)
        }
        
        if let output = output {
            let outputOutlet = ValueOutlet(value: output, direction: .output, index: 0, frame: self.view.frame, container: self)
            boolOutlets.append(outputOutlet)
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
