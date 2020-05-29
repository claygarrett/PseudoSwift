//
//  WorkspaceViewController.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 4/21/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit
import PseudoSwift
import Foundation

public class WorkspaceViewController: UIViewController, ConnectionDragHandler, FunctionStepSelectionDelegate {
    
    var currentFunction: Function<Bool> = Function<Bool>(name: "Main Function")
    var boolWires: [Wire<Bool>] = []
    var activeWire: Wire<Bool>?
    var containers: [Container] = []
    
    let functionList = FunctionListTableViewController(functions: ["DefineBool", "SetBool", "BoolFlip", "BoolAnd", "FunctionOutput"])
    let runButton = UIButton()
    var functionSteps: [FunctionStep] = []
    var booleanVariables: [ValueGettable<Bool>] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        addFunctionContainer(name: "FunctionStart", inputVariables: [], outputVariable: nil)
        addFunctionList()
        addButton()
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
    
    func addButton() {
        runButton.frame = .init(x: 20, y: 20, width: 100, height: 40)
        runButton.backgroundColor = .purple
        runButton.setTitle("Run!", for: .normal)
        runButton.setTitleColor(.white, for: .normal    )
        runButton.layer.cornerRadius = 10
        runButton.addTarget(self, action: #selector(WorkspaceViewController.runTapped(_:)), for: .touchUpInside)
        view.addSubview(runButton)
    }
    
    @objc func runTapped(_ sender:UIButton!) {
        let funcVal = try?currentFunction.callAsFunction()
        print(funcVal ?? "Nil")
    }
    
    func layoutSubviews() {
        let workspaceWidth = self.view.frame.size.width
        let workspaceHeight = self.view.frame.size.height
        
        for container in containers {
            
            let newContainerFrame = CGRect(
                x: container.positionPercentage.x * workspaceWidth,
                y: container.positionPercentage.y * workspaceHeight,
                width: Container.containerWidth,
                height: Container.containerHeight)
            container.view.frame = newContainerFrame
        }
        
        let functionListWidth: CGFloat = 200
        
        functionList.view.frame = CGRect(x: self.view.frame.size.width - functionListWidth, y: 0, width: functionListWidth, height: self.view.frame.size.height)
    }
    
    func addDefVariableContainer(value: ValueSettable<Bool>, outputVariable: VariableDefinition) {
        let container = DefVariableContainer(value: value, positionPercentage: CGPoint(x: 0.1, y: 0.1), output: outputVariable)
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addSetVariableContainer(value: ValueSettable<Bool>) {
        let container = SetVariableContainer<Bool>(value: value, positionPercentage: CGPoint(x: 0.1, y: 0.1))
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addFunctionContainer(name: String, inputVariables: [ValueSettable<Bool>], outputVariable: ValueSettable<Bool>?) {
        let container = FunctionContainer(positionPercentage: CGPoint(x: 0.1, y: 0.1), inputs: inputVariables, output: outputVariable, name: name)
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addOutputContainer(value: ValueSettable<Bool>) {
        let container = OutputContainer(value: value, positionPercentage: CGPoint(x: 0.1, y: 0.1), name: value.name)
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addFunctionList() {
        self.view.addSubview(functionList.view)
        self.addChild(functionList)
        
        functionList.view.backgroundColor = .purple
        functionList.selectionDelegate = self
    }
    
    func didStartConnectionDragHandlerFromView<ValueType>(from fromContainer: Container, outlet: Outlet<ValueType>) {
        switch outlet {
        case let castedOutlet as ValueOutlet<Bool>:
            didStartConnectionDragHandlerFromView(from: fromContainer, outlet: castedOutlet)
        case let castedOutlet as FlowOutlet<Bool>:
            didStartConnectionDragHandlerFromView(from: fromContainer, outlet: castedOutlet)
        default:
            return
        }
    }
    
    func didStartConnectionDragHandlerFromView(from fromContainer: Container, outlet: ValueOutlet<Bool>) {
        switch outlet.direction {
        case .input:
            self.activeWire = getWire(sourceOutlet: nil, destinationOutlet: outlet)
        case .output:
            self.activeWire = getWire(sourceOutlet: outlet, destinationOutlet: nil)
        }
    }
    
    func didStartConnectionDragHandlerFromView(from fromContainer: Container, outlet: FlowOutlet<Bool>) {
        switch outlet.direction {
        case .input:
            self.activeWire = getWire(sourceOutlet: nil, destinationOutlet: outlet)
        case .output:
            self.activeWire = getWire(sourceOutlet: outlet, destinationOutlet: nil)
        }
    }
    
    func getWire(sourceOutlet: FlowOutlet<Bool>?, destinationOutlet: FlowOutlet<Bool>?) -> Wire<Bool>? {
        sourceOutlet?.clearWire()
        destinationOutlet?.clearWire()
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        let wire = Wire(type: .flow, sourceOutlet: sourceOutlet, destinationOutlet: destinationOutlet, nibName: "Wire", bundle: bundle)
        self.view.addSubview(wire.view)
        self.addChild(wire)
        sourceOutlet?.wire = wire
        destinationOutlet?.wire = wire
        return wire
        
    }
    
    func getWire<WireType>(sourceOutlet: ValueOutlet<WireType>?, destinationOutlet: ValueOutlet<WireType>?) -> Wire<WireType>? {
        destinationOutlet?.clearWires()
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        let wire = Wire(type: .value, sourceOutlet: sourceOutlet, destinationOutlet: destinationOutlet, nibName: "Wire", bundle: bundle)
        self.view.addSubview(wire.view)
        self.addChild(wire)
        sourceOutlet?.addWire(wire: wire)
        destinationOutlet?.addWire(wire: wire)
        return wire
    }
    
    func didDragConnectionHandlerFromView(from fromContainer: Container, atPosition: CGPoint, to toPosition: CGPoint) {
        let containerViewFrame = fromContainer.view.frame
        let inputHandlePosition = containerViewFrame.origin.movedBy(
            translationPoint: CGPoint(x: atPosition.x, y: atPosition.y)
        )
        
        activeWire?.updateWireFrame(
            inputHandlePosition: inputHandlePosition, outputHandlePosition: inputHandlePosition.movedBy(
                translationPoint: CGPoint(x: toPosition.x - atPosition.x, y: toPosition.y - atPosition.y  ))
        )
    }
    
    func didEndConnectionDragHandlerFromView<OutletType>(from fromContainer: Container, fromOutlet: Outlet<OutletType>, toEndPosition endPosition: CGPoint) {
        if let valueOutlet = fromOutlet as? ValueOutlet<Bool> {
            didEndConnectionDragHandlerFromView(from: fromContainer, fromOutlet: valueOutlet, toEndPosition: endPosition)
        } else if let flowOutlet = fromOutlet as? FlowOutlet<Bool> {
            didEndConnectionDragHandlerFromView(from: fromContainer, fromOutlet: flowOutlet, toEndPosition: endPosition)
        }
    }
    
    func didEndConnectionDragHandlerFromView(from fromContainer: Container, fromOutlet: FlowOutlet<Bool>, toEndPosition endPosition: CGPoint) {
        // our end position is measured from the center of the connector
        // we want our hit test to be measured from the top-left corner
        let adjustedEndPosition = endPosition
        
        for container in containers.compactMap({ $0 as? FlowContainer<Bool> }) {
            // NOTE: We only do this for FlowContainers and do it on their input/output outlets
            let flowOutlet: FlowOutlet<Bool>?
            switch fromOutlet.direction {
            case .input:
                flowOutlet = container.outputFlowOutlet
            case .output:
                flowOutlet = container.inputFlowOutlet
            }
            
            guard let outlet = flowOutlet else {
                continue
            }
            
            let inlet = outlet.view.inlet
            let locationConnectableView = fromContainer.view.convert(adjustedEndPosition, to: inlet)
            if(inlet.point(inside: locationConnectableView, with: nil)) {
                makeConnection(sourceOutlet: fromOutlet, destinationOutlet: outlet)
                return
            }
            
            
        }
        
        activeWire?.view.removeFromSuperview()
        activeWire?.removeFromParent()
        activeWire = nil
    }
    
    func didEndConnectionDragHandlerFromView(from fromContainer: Container, fromOutlet: ValueOutlet<Bool>, toEndPosition endPosition: CGPoint) {
        // our end position is measured from the center of the connector
        // we want our hit test to be measured from the top-left corner
        let adjustedEndPosition = endPosition
        
        for container in containers {
            for outlet in container.boolOutlets.compactMap({ $0 as? ValueOutlet}) {
                let inlet = outlet.view.inlet
                let locationConnectableView = fromContainer.view.convert(adjustedEndPosition, to: inlet)
                if(inlet.point(inside: locationConnectableView, with: nil)) {
                    makeConnection(sourceOutlet: fromOutlet, destinationOutlet: outlet)
                    return
                }
            }
        }
        
        activeWire?.view.removeFromSuperview()
        activeWire?.removeFromParent()
        activeWire = nil
    }
    
    /// Makes a connection between two nodes of compatible input/output types. This essentailly represents
    /// a variable present in both the source and destination function steps.
    /// - Parameters:
    ///   - sourceOutlet: The source outlet
    ///   - destinationOutlet: The destination outlet
    func makeConnection(
        sourceOutlet: ValueOutlet<Bool>,
        destinationOutlet: ValueOutlet<Bool>
    ) {
        
        sourceOutlet.value.follow(follower: destinationOutlet.value)
        
        guard let activeWire = self.activeWire else { return }
        if sourceOutlet.direction == destinationOutlet.direction {
            fatalError("Cannot connect outlets of the same direction")
        }
        
        destinationOutlet.clearIncomingWires()
        
        switch destinationOutlet.direction {
        case .input:
            activeWire.destinationOutlet = destinationOutlet
        case .output:
            activeWire.sourceOutlet = destinationOutlet
        }
        
        destinationOutlet.addWire(wire: activeWire)
        boolWires.append(activeWire)
        self.activeWire = nil
    }
    
    /// Makes a connection between two nodes of compatible input/output types. This essentailly represents
    /// a variable present in both the source and destination function steps.
    /// - Parameters:
    ///   - sourceOutlet: The source outlet
    ///   - destinationOutlet: The destination outlet
    func makeConnection(
        sourceOutlet: FlowOutlet<Bool>,
        destinationOutlet: FlowOutlet<Bool>) {
        
        guard let activeWire = self.activeWire else { return }
        if sourceOutlet.direction == destinationOutlet.direction {
            fatalError("Cannot connect outlets of the same direction")
        }
        
        switch destinationOutlet.direction {
        case .input:
            activeWire.destinationOutlet = destinationOutlet
        case .output:
            activeWire.sourceOutlet = destinationOutlet
        }
        
        destinationOutlet.wire = activeWire
        boolWires.append(activeWire)
        self.activeWire = nil
    }
    
    // MARK: - FunctionStepSelectionDelegate
    
    func didSelectFunction(functionStep: String) {
        switch functionStep {
            
        case "BoolAnd":
            let leftVar = ValueSettable("leftVar", false)
            let rightVar = ValueSettable("rightVar", false)
            let varToSet = ValueSettable("varToSet", false)
            currentFunction.addLine(leftVar)
            currentFunction.addLine(rightVar)
            currentFunction.addLine(varToSet)
            let boolAndStep = BoolAnd(varToSet: "varToSet", leftVar: "leftVar", rightVar: "rightVar")
            addFunctionContainer(name: "BoolAnd", inputVariables: [leftVar, rightVar], outputVariable: varToSet)
            currentFunction.addLine(boolAndStep)
        case "BoolFlip":
            let input = ValueSettable<Bool>("target", true)
            addFunctionContainer(name: "target", inputVariables: [input], outputVariable: input)
            currentFunction.addLine(input)
            currentFunction.addLine(BoolFlip("target"))
        case "FunctionOutput":
            let id = UUID().uuidString
            let variable = ValueSettable<Bool>(id, false)
            let output = FunctionOutput(name: id)
            currentFunction.addLine(variable)
            currentFunction.addLine(output)
            addOutputContainer(value: variable)
        case "DefineBool":
            let guid = UUID().uuidString
            let boolAndStep = Var(guid, false)
            addDefVariableContainer(value: boolAndStep, outputVariable: VariableDefinition(name: guid, type: .boolean, direction: .output))
            currentFunction.addLine(boolAndStep)
        case "SetBool":
            let varToSetName = UUID().uuidString
            let varToSetFromName = UUID().uuidString
            let varToSet = ValueSettable<Bool>(varToSetName, true)
            let varToSetFrom = ValueSettable<Bool>(varToSetFromName, true)
            
            let setVarToVar = SetBoolEqualTo(varToSetName: varToSetName, varWithValueName: varToSetFromName)
            addSetVariableContainer(value: varToSet)
            currentFunction.addLine(varToSet)
            currentFunction.addLine(varToSetFrom)
            currentFunction.addLine(setVarToVar)
        default:
            break
        }
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
