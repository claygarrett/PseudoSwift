
import UIKit
import PseudoSwift


public final class SetVariableContainer<ValueType>: FlowContainer<ValueType>, UITextFieldDelegate {

    let value: ValueSettable<Bool>
    var valueOutlet: ValueOutlet<Bool>!
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint) {
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name, isFlowConductor: true)
    }
    
    public override func viewDidLoad() {
        valueOutlet = InputValueOutlet(value: value, index: 1, frame: self.view.frame, container: self)
        boolOutlets.append(valueOutlet)
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
