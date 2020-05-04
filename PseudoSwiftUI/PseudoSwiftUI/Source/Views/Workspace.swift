//
//  WorkspaceViewController.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 4/21/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit

public class WorkspaceViewController: UIViewController, ConnectionDragHandler {
    
    
    var connections: [Connection] = []
    var activeWire: Wire?
    var containers: [ContainerViewController] = []
    let containerWidth: CGFloat = 200
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        addContainer(leftPercent: 0.35, topPercent: 0.3)
        addContainer(leftPercent: 0.4, topPercent: 0.63)
        addContainer(leftPercent: 0.3, topPercent: 0.8)
        addContainer(leftPercent: 0.1, topPercent: 0.7)
    }
    
    enum VerticalDirection {
        case top
        case bottom
    }
    
    enum HorizontalDirection {
        case left
        case right
    }
    
    public override func viewDidLayoutSubviews() {
        layoutSubviews()
    }
    
    func layoutSubviews() {
        let workspaceWidth = self.view.frame.size.width
        let workspaceHeight = self.view.frame.size.height
        
        for container in containers {
            
            let newContainerFrame = CGRect(
            x: container.positionPercentage.x * workspaceWidth,
            y: container.positionPercentage.y * workspaceHeight,
            width: containerWidth,
            height: containerWidth)
            container.view.frame = newContainerFrame
        }
    }
    
    func addContainer(leftPercent: CGFloat, topPercent: CGFloat) {
       let inputVariable = VariableViewModel(name: "inputVariable", type: .boolean)
        let outputVariable = VariableViewModel(name: "outputVariable", type: .boolean)
        let container = ContainerViewController(positionPercentage: CGPoint(x: leftPercent, y: topPercent), input: inputVariable, output: outputVariable, name: "multiplyNums")
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
         self.containers.append(container)
    }
    
  
    
    func didStartConnectionDragHandlerFromView(from fromContainer: ContainerViewController, outlet: Outlet) {
        let wire = getBlankWire()
        self.activeWire = wire
    }
    
    func getBlankWire() -> Wire {
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        let wire = Wire(nibName: "Wire", bundle: bundle)
        self.view.addSubview(wire.view)
        self.addChild(wire)
        return wire
    }
    
    func didDragConnectionHandlerFromView(from fromContainer: ContainerViewController, atPosition: CGPoint, to toPosition: CGPoint) {
        
        let containerViewFrame = fromContainer.view.frame
        let inputHandlePosition = containerViewFrame.origin.movedBy(
            translationPoint: CGPoint(x: atPosition.x, y: atPosition.y)
        )
        
        activeWire?.updateWireFrame(
            inputHandlePosition: inputHandlePosition, outputHandlePosition: inputHandlePosition.movedBy(
                translationPoint: CGPoint(x: toPosition.x - atPosition.x, y: toPosition.y - atPosition.y  ))
        )
        
    }
    
    func didEndConnectionDragHandlerFromView(from fromContainer: ContainerViewController, fromOutlet: Outlet, toEndPosition endPosition: CGPoint) {
        // our end position is measured from the center of the connector
        // we want our hit test to be measured from the top-left corner
        let adjustedEndPosition = endPosition
        
        for container in containers {
            for outlet in container.outlets {
                let locationConnectableView = fromContainer.view.convert(adjustedEndPosition, to: outlet.view)
                if(outlet.view.point(inside: locationConnectableView, with: nil)) {
                    print("True \(container.view!.frame)")
                    makeConnection(
                        sourceContainer: fromContainer,
                        sourceOutlet: fromOutlet,
                        destinationContainer: container,
                        destinationOutlet: outlet)
                    return
                }
            }
        }
        
        activeWire?.view.removeFromSuperview()
        activeWire?.removeFromParent()
        activeWire = nil
    }
    
    func makeConnection(
        sourceContainer: ContainerViewController,
        sourceOutlet: Outlet,
        destinationContainer: ContainerViewController,
        destinationOutlet: Outlet) {
        
  
        
        guard let activeWire = self.activeWire else { return }
        if sourceOutlet.type == destinationOutlet.type {
            fatalError("Cannot connect the same type of outlets")
        }
        
        if sourceOutlet.type == .inputFlow || sourceOutlet.type == .outputFlow || destinationOutlet.type == .inputFlow || destinationOutlet.type == .outputFlow {
            fatalError("Haven't implemented flow connections yet")
        }
        
        let placedWire = activeWire
        self.activeWire = nil
        
        sourceOutlet.clearConnection()
        destinationOutlet.clearConnection()

        
        let connection = Connection(sourceOutlet: sourceOutlet, destintationOutlet: destinationOutlet, wire: placedWire)
        sourceOutlet.connection = connection
        destinationOutlet.connection = connection
        connections.append(connection)
        let inputOutlet = sourceOutlet.type == OutletType.inputValue ? sourceOutlet : destinationOutlet
        let outputOutlet = sourceOutlet.type == OutletType.outputValue ? sourceOutlet : destinationOutlet
        placedWire.inputOutlet = inputOutlet
        placedWire.outputOutlet = outputOutlet
    }
}

extension CGPoint {
    func movedBy(translationPoint: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + translationPoint.x, y: self.y + translationPoint.y)
    }
    
    func movedBy(vector: CGVector) -> CGPoint {
        return CGPoint(x: self.x + vector.dx, y: self.y + vector.dy)
    }
    
    func movedBySquare(ofWidth width: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + width, y: self.y + width)
    }
}

extension CGSize {
    func resizedBy(vector: CGVector) -> CGSize {
        return CGSize(width: width + vector.dx, height: height + vector.dy)
    }
}


extension CGRect {
    
    enum Corner {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    func movingCorner(vector: CGVector, corner: Corner) -> CGRect {
        
        let newOrigin: CGPoint
        let newSize: CGSize
        
        switch corner {
        case .topLeft:
            newOrigin = origin.movedBy(vector: vector)
            newSize = size.resizedBy(vector: vector)
        case .topRight:
            newOrigin = origin.movedBy(vector: CGVector(dx: 0, dy: vector.dy))
            newSize = size.resizedBy(vector: vector)
        case .bottomLeft:
            newOrigin = origin.movedBy(vector: CGVector(dx: vector.dx, dy: 0))
            newSize = size.resizedBy(vector: vector)
        case .bottomRight:
            newOrigin = origin
            newSize = size.resizedBy(vector: vector)
        }
        
        return CGRect(origin: newOrigin, size: newSize)
    }
}
