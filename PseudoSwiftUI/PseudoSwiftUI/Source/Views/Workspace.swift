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
    var connections: [Connection] = []
    var activeWire: Wire?
    var containers: [Container] = []
    let containerWidth: CGFloat = 300
    let containerHeight: CGFloat = 200
    let functionList = FunctionListTableViewController(functions: ["DefineBool", "SetBool", "BoolFlip", "BoolAnd", "FunctionOutput"])
    let runButton = UIButton()
    var functionSteps: [FunctionStep] = []
    var booleanVariables: [ValueGettable<Bool>] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
//        addFunctionContainer(name: "FunctionStart", inputVariables: [], outputVariable: nil)
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
                width: containerWidth,
                height: containerHeight)
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
        let container = SetVariableContainer(value: value, positionPercentage: CGPoint(x: 0.1, y: 0.1))
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
    
    func didStartConnectionDragHandlerFromView(from fromContainer: Container, outlet: ValueOutlet) {
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
    
    func didEndConnectionDragHandlerFromView(from fromContainer: Container, fromOutlet: ValueOutlet, toEndPosition endPosition: CGPoint) {
        // our end position is measured from the center of the connector
        // we want our hit test to be measured from the top-left corner
        let adjustedEndPosition = endPosition
        
        for container in containers {
            for outlet in container.outlets.compactMap({ $0 as? ValueOutlet}) {
                let inlet = (outlet.view ).inlet
                let locationConnectableView = fromContainer.view.convert(adjustedEndPosition, to: inlet)
                if(inlet.point(inside: locationConnectableView, with: nil)) {
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
    
    /// Makes a connection between two nodes of compatible input/output types. This essentailly represents
    /// a variable present in both the source and destination function steps.
    /// - Parameters:
    ///   - sourceContainer: The container of the source outlet.
    ///   - sourceOutlet: The source outlet
    ///   - destinationContainer: The container of the destination outlet
    ///   - destinationOutlet: The destination outlet
    func makeConnection(
        sourceContainer: Container,
        sourceOutlet: ValueOutlet,
        destinationContainer: Container,
        destinationOutlet: ValueOutlet) {
        
        sourceOutlet.value.follow(follower: destinationOutlet.value)
        
        guard let activeWire = self.activeWire else { return }
        if sourceOutlet.type == destinationOutlet.type {
            fatalError("Cannot connect the same type of outlets")
        }
        
        if sourceOutlet.type == .inputFlow || sourceOutlet.type == .outputFlow || destinationOutlet.type == .inputFlow || destinationOutlet.type == .outputFlow {
            fatalError("Haven't implemented flow connections yet")
        }
        
        let placedWire = activeWire
        self.activeWire = nil
        
//        sourceOutlet.clearConnection()
        destinationOutlet.clearIncomingConnections()
        
        
        let connection = Connection(sourceOutlet: sourceOutlet, destintationOutlet: destinationOutlet, wire: placedWire)
        sourceOutlet.addConnection(connection: connection)
        destinationOutlet.addConnection(connection: connection)
        connections.append(connection)
        let inputOutlet = sourceOutlet.type == OutletType.inputValue ? sourceOutlet : destinationOutlet
        let outputOutlet = sourceOutlet.type == OutletType.outputValue ? sourceOutlet : destinationOutlet
        placedWire.inputOutlet = inputOutlet
        placedWire.outputOutlet = outputOutlet
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
