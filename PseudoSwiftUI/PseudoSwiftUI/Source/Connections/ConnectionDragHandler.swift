
import UIKit

protocol ConnectionDragHandler: AnyObject {
    func didStartConnectionDragHandlerFromView(from fromContainer: Container, outlet: ValueOutlet)
    func didDragConnectionHandlerFromView(from fromContainer: Container, atPosition: CGPoint, to position: CGPoint)
    func didEndConnectionDragHandlerFromView(from fromContainer: Container, fromOutlet: ValueOutlet, toEndPosition: CGPoint)
}
