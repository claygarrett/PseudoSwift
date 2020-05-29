
import UIKit
import PseudoSwift


public final class SetVariableContainer<ValueType>: FlowContainer<ValueType>, UITextFieldDelegate {

    let value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint) {
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name, isFlowConductor: true)
    }
    
    public override func viewDidLoad() {
        let inputValueOutlet = ValueOutlet(value: value, direction: .input, index: 1, frame: self.view.frame, container: self)
        boolOutlets.append(inputValueOutlet)
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
