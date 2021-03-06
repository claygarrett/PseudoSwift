
import UIKit
import PseudoSwift


final class DefVariableContainer: ValueProviderContainer, UITextFieldDelegate {

    var textBox: UITextField!
    let toggle: UISwitch
    
    init(positionPercentage: CGPoint, output: Variable<Bool>) {
        self.toggle = UISwitch()
        toggle.isOn = (try? output.getValue()) ?? false
        super.init(positionPercentage: positionPercentage, output: output, name: output.name, isFlowConductor: false)
    }
    
    override func viewDidLoad() {
        let outputOutlet = OutputValueOutlet(
            value: self.output,
            index: 0,
            frame: self.view.frame,
            container: self,
            title: self.output.name)
        boolOutlets.append(outputOutlet)
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
        toggle.frame = CGRect(x: 20, y: 50, width: 200, height: 40)
        
        toggle.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        
        self.view.addSubview(textBox)
        self.view.addSubview(toggle)
        
        textBox.addTarget(self, action: #selector(DefVariableContainer.textChanged(textbox:)), for: .editingChanged)
    }
    
     @objc func stateChanged(switchState: UISwitch) {
        output.setDefaultValue(switchState.isOn)
    }
    
    @objc func textChanged(textbox: UITextView) {
        let name = self.textBox.text ?? ""
        if let outlet = self.boolOutlets.first as? ValueOutlet {
            outlet.updateVariableName(name: name)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
