
import UIKit
import PseudoSwift

final class FunctionOutputContainer: ValueProviderContainer {
    
    let nameLabel: UILabel = UILabel()
    let value: Variable<Bool>
    
    init(value: Variable<Bool>, positionPercentage: CGPoint, name: String) {
        self.value = value
        super.init(
            positionPercentage: positionPercentage,
            output: value,
            name: name,
            isFlowConductor: false
        )
    }
    
    override func viewDidLoad() {
        let inputOutlet = InputValueOutlet(
            value: value,
            index: 0,
            frame: self.view.frame,
            container: self,
            title: "Function Output"
        )
        boolOutlets.append(inputOutlet)
        
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw() {
        nameLabel.text = name
        nameLabel.frame = CGRect(x: 10, y: 10, width: 200, height: 20)
        nameLabel.textColor = .white
        self.view.addSubview(nameLabel)
    }
    

}
