
import UIKit
import PseudoSwift


public final class StartFlowContainer: FlowContainer, UITextFieldDelegate {

    
    init( positionPercentage: CGPoint) {
        super.init(positionPercentage: positionPercentage, name: "Start", isFlowConductor: true)
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
