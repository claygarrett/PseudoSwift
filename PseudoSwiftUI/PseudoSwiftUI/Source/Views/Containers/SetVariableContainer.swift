
import UIKit
import PseudoSwift


final class SetVariableContainer: Container, UITextFieldDelegate {

    let value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint) {
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name)
    }
    
    override func viewDidLoad() {
        let inputFlowOutlet = FlowOutlet(type: .inputFlow, index: 0, frame: self.view.frame)
        let inputValueOutlet = ValueOutlet(value: value, type: .inputValue, index: 1, frame: self.view.frame)
        outlets.append(inputFlowOutlet)
        outlets.append(inputValueOutlet)
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
     
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
