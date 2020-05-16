
import UIKit
import PseudoSwift


final class DefVariableContainer: Container, UITextFieldDelegate {

    var textBox: UITextField!
    let output: VariableDefinition
    let toggle: UISwitch
    let value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint, output: VariableDefinition) {
        self.output = output
        self.toggle = UISwitch()
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name, isFlowConductor: false)
    }
    
    override func viewDidLoad() {
        let outputOutlet = ValueOutlet(value: value, type: .outputValue, index: 0, frame: self.view.frame)
        outlets.append(outputOutlet)
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        textBox = UITextField()
        textBox.text = name
        textBox.frame = CGRect(x: 20, y: 20, width: 120, height: 20)
        textBox.font = .boldSystemFont(ofSize: 24)
        textBox.textColor = .systemPink
        textBox.delegate = self
        toggle.frame = CGRect(x: 20, y: 50, width: 100, height: 40)
        
        toggle.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        
        self.view.addSubview(textBox)
        self.view.addSubview(toggle)
        
        textBox.addTarget(self, action: #selector(DefVariableContainer.textChanged(textbox:)), for: .editingChanged)
    }
    
     @objc func stateChanged(switchState: UISwitch) {
        value.setValue(switchState.isOn)
    }
    
    @objc func textChanged(textbox: UITextView) {
        let name = self.textBox.text ?? ""
        if let outlet = self.outlets.first as? ValueOutlet {
            outlet.updateVariableName(name: name)
        }
        
//        value.name = name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
