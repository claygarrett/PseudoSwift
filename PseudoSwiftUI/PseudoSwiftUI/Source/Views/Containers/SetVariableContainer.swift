
import UIKit
import PseudoSwift

protocol CustomVariableNameProvider: AnyObject {
    var numCustomVariables: Int { get }
    var customVariableNames: [String] { get }
    func getValue(name: String) -> Variable<Bool>?
}


public final class SetVariableContainer<ValueType>: FlowContainer, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customVariableNameProvider?.customVariableNames[row]
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customVariableNameProvider?.numCustomVariables ?? 0
    }

    var value: Variable<Bool>
    var valueOutlet: SetValueOutlet<Bool>!
    let picker: UIPickerView = UIPickerView()
    let variableToSetTextField: UITextField = UITextField()
    weak var customVariableNameProvider: CustomVariableNameProvider?
    
    init(value: Variable<Bool>, positionPercentage: CGPoint) {
        self.value = value
        super.init(positionPercentage: positionPercentage, name: value.name, isFlowConductor: true)
    }
    
    public override func viewDidLoad() {
        picker.dataSource = self as UIPickerViewDataSource
        picker.delegate = self as UIPickerViewDelegate
        view.addSubview(variableToSetTextField)
        valueOutlet = SetValueOutlet(value: value, index: 1, frame: self.view.frame, container: self)
        boolOutlets.append(valueOutlet)
        super.viewDidLoad()
    }
    
    public override func viewDidLayoutSubviews() {
        variableToSetTextField.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        variableToSetTextField.inputView = picker
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        dismissPickerView()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Capture the picker view selection
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        let selectedVariableName = customVariableNameProvider?.customVariableNames[row]
        if
            let name = selectedVariableName,
            let customVariableNameProvider = customVariableNameProvider,
            let value = customVariableNameProvider.getValue(name: name)
        {
            self.value = value
            let wire = self.valueOutlet.wire
            self.valueOutlet.wire = nil
            valueOutlet = SetValueOutlet(value: value, index: 1, frame: self.view.frame, container: self)
            valueOutlet.wire = wire
        }
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       variableToSetTextField.inputAccessoryView = toolBar
    }
    
    @objc func action() {
          view.endEditing(true)
    }
}
