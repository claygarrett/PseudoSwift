
import UIKit

protocol ConnectionDragHandler: AnyObject {
    func didStartConnectionDragHandlerFromView(from fromContainer: ContainerViewController, outlet: Outlet)
    func didDragConnectionHandlerFromView(from fromContainer: ContainerViewController, atPosition: CGPoint, to position: CGPoint)
    func didEndConnectionDragHandlerFromView(from fromContainer: ContainerViewController, fromOutlet: Outlet, toEndPosition: CGPoint)
}
