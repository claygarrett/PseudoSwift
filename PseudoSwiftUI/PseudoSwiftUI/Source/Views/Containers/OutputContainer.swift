
import UIKit
import PseudoSwift

final class OutputContainer: Container {
    
    let nameLabel: UILabel = UILabel()
    let value: ValueSettable<Bool>
    
    init(value: ValueSettable<Bool>, positionPercentage: CGPoint, name: String) {
        self.value = value
        super.init(positionPercentage: positionPercentage, name: name, isFlowConductor: false)
    }
    
    override func viewDidLoad() {
        let outputOutlet = ValueOutlet(value: value, direction: .input , index: 0, frame: self.view.frame, container: self)
            boolOutlets.append(outputOutlet)
        
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
