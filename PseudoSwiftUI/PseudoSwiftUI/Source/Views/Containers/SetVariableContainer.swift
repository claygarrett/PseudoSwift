
import UIKit
import PseudoSwift


final class SetVariableContainer: Container, UITextFieldDelegate {

    let toggle: UISwitch
    let value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint) {
        self.toggle = UISwitch()
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name)
    }
    
    override func viewDidLoad() {
        let inputFlowOutlet = FlowOutlet(type: .outputValue, index: 0, frame: self.view.frame)
        outlets.append(inputFlowOutlet)
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
     
        toggle.frame = CGRect(x: 20, y: 50, width: 100, height: 40)
        

        self.view.addSubview(toggle)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
