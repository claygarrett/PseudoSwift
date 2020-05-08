
import UIKit
import PseudoSwift


final class VariableContainer: Container {

    var textBox: UITextField!
    let output: VariableDefinition
    
    init(positionPercentage: CGPoint, output: VariableDefinition, name: String) {
        self.output = output
        super.init(positionPercentage: positionPercentage, name: name)
        
        
    }
    
    override func viewDidLoad() {
        let outputOutlet = Outlet(type: .outputValue, inputVariable: output, index: 0, frame: self.view.frame)
        outlets.append(outputOutlet)
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
        self.view.addSubview(textBox)
    }
    
}
