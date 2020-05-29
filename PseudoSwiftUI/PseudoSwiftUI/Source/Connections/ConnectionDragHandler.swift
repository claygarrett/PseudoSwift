
import UIKit

protocol ConnectionDragHandler: AnyObject {
    
    func didStartConnectionDragHandlerFromView<ValueType>(from fromContainer: Container, outlet: Outlet<ValueType>)
    func didDragConnectionHandlerFromView(from fromContainer: Container, atPosition: CGPoint, to position: CGPoint)
    func didEndConnectionDragHandlerFromView<ValueType>(from fromContainer: Container, fromOutlet: Outlet<ValueType>, toEndPosition: CGPoint)
}
