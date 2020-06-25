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

public class WorkspaceViewController: UIViewController, ConnectionDragHandler, FunctionStepSelectionDelegate, CustomVariableNameProvider {
    func getValue(name: String) -> Variable<Bool>? {
        return variables.first(where: { $0.name == name })
    }
    
    
    var currentFunction: Function<Bool> = Function<Bool>(name: "Main Function")
    var boolWires: [Wire<Bool>] = []
    var activeWire: Wire<Bool>?
    var containers: [Container] = []
    var startContainer: StartFlowContainer!
    var functionOutputContainer: FunctionOutputContainer
    let functionList = FunctionListTableViewController(functions: ["DefineBool", "SetBool", "BoolFlip", "BoolAnd"])
    let runButton = UIButton()
    var functionSteps: [FunctionStep] = []
    var variables: [Variable<Bool>] = []
    var flowManager: FlowManager!
    let variableNameGenerator: VariableNameGenerator = VariableNameGenerator()
    
    required init?(coder: NSCoder) {
        let outputValue = Variable<Bool>(name: UUID().uuidString)
        functionOutputContainer = FunctionOutputContainer(value: outputValue, positionPercentage: CGPoint(x: 0.5, y: 0.5), name: "Function Output")
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        super.init(nibName: "WorkspaceViewController", bundle: bundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        
        addStartContainer()
        addFunctionOutputContainer()
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
        runButton.frame = .init(x: 20, y: 20, width: 200, height: 40)
        runButton.backgroundColor = .purple
        runButton.setTitle("Run!", for: .normal)
        runButton.setTitleColor(.white, for: .normal    )
        runButton.layer.cornerRadius = 10
        runButton.addTarget(
            self,
            action: #selector(WorkspaceViewController.runTapped(_:)),
            for: .touchUpInside
        )
        view.addSubview(runButton)
    }
    
    @objc func runTapped(_ sender:UIButton!) {
        for variable in variables {
            variable.reset()
        }
        let function = flowManager.buildFunction()
        let functionValue = try?function.callAsFunction()
        print(functionValue ?? "Nil")
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
    
    func addStartContainer() {
        startContainer = StartFlowContainer(positionPercentage: CGPoint(x: 0.1, y: 0.01))
        flowManager = FlowManager(
            rootNode: startContainer,
            functionOutputContainer: functionOutputContainer
        )
        startContainer.dragDelegate = self
        self.containers.append(startContainer)
        self.addChild(startContainer)
        self.view.addSubview(startContainer.view)
    }
    
    func addFunctionOutputContainer() {
        self.containers.append(functionOutputContainer)
        self.addChild((functionOutputContainer))
        self.view.addSubview((functionOutputContainer).view)
    }
    
    func addDefVariableContainer(output: Variable<Bool>) {
        let container = DefVariableContainer(positionPercentage: CGPoint(x: 0.1, y: 0.1), output: output)
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addSetVariableContainer(value: Variable<Bool>) {
        let container = SetVariableContainer<Bool>(value: value, positionPercentage: CGPoint(x: 0.1, y: 0.1))
        container.customVariableNameProvider = self
        container.dragDelegate = self
        self.addChild(container)
        self.view.addSubview(container.view)
        self.containers.append(container)
    }
    
    func addFunctionStepContainer(functionStep: FunctionStep, name: String, inputVariables: [Variable<Bool>], output: Variable<Bool>) {
        let container = FunctionStepContainer(functionStep: functionStep, positionPercentage: CGPoint(x: 0.1, y: 0.1), inputs: inputVariables, output: output, name: name)
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
        switch outlet {
        case let input as InputValueOutlet<Bool>:
            self.activeWire = getWire(sourceOutlet: nil, destinationOutlet: input)
        case let output as OutputValueOutlet<Bool>:
            self.activeWire = getWire(sourceOutlet: output, destinationOutlet: nil)
        default:
            return
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
    
    func getWire<WireType>(sourceOutlet: OutputValueOutlet<WireType>?, destinationOutlet: InputValueOutlet<WireType>?) -> Wire<WireType>? {
        destinationOutlet?.clearWire()
        let bundle = Bundle(identifier: "com.claygarrett.PseudoSwiftUI")
        let wire = Wire(type: .value, sourceOutlet: sourceOutlet, destinationOutlet: destinationOutlet, nibName: "Wire", bundle: bundle)
        self.view.addSubview(wire.view)
        self.addChild(wire)
        sourceOutlet?.addWire(wire: wire)
        destinationOutlet?.wire = wire
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
        
        for container in containers.compactMap({ $0 as? FlowContainer }) {
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
        
        activeWire?.detach()
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
        
        // TODO: Clean this shit up. It's messy
        // setValue vs Follow
        switch sourceOutlet {
        case is InputValueOutlet<Bool>:
            //            input.clearWire()
            let output = destinationOutlet as! OutputValueOutlet<Bool>
            output.addWire(wire: activeWire)
            destinationOutlet.value.follow(follower: sourceOutlet.value)
            
        case is OutputValueOutlet<Bool>:
            if let input = destinationOutlet as? InputValueOutlet<Bool> {
                input.clearWire()
                input.wire = activeWire
                sourceOutlet.value.follow(follower: destinationOutlet.value)
            } else if let setValue = destinationOutlet as? SetValueOutlet<Bool> {
                setValue.clearWire()
                setValue.wire = activeWire
            }
        default: break
        }
        
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
            let leftVar = Variable("leftVar", false)
            let rightVar = Variable("rightVar", false)
            let varToSet = Variable("varToSet", false)
            currentFunction.addLine(leftVar)
            currentFunction.addLine(rightVar)
            currentFunction.addLine(varToSet)
            let boolAndStep = BoolAnd(varToSet: "varToSet", leftVar: "leftVar", rightVar: "rightVar")
            addFunctionStepContainer(functionStep: boolAndStep, name: "BoolAnd", inputVariables: [leftVar, rightVar], output: varToSet)
        case "BoolFlip":
            let inputId = UUID().uuidString
            let outputId = UUID().uuidString
            let input = getOrAddVariable(name: inputId, defaultValue: true, title: "Variable to Flip")
            let output = getOrAddVariable(name: outputId, defaultValue: true, title: "Value after Flip")
            addFunctionStepContainer(functionStep: BoolFlip(sourceVariableName: inputId, destinationVariableName: outputId), name: "Flip Boolean", inputVariables: [input], output: output)
        case "DefineBool":
            let variableName = variableNameGenerator.getUniqueVariableName()
            
            let varToSet = getOrAddVariable(name: variableName, defaultValue: false)
            
            
            addDefVariableContainer(output: varToSet)
        case "SetBool":
            let varToSet = getOrAddVariable(name: "", defaultValue: false)
            addSetVariableContainer(value: varToSet)
        default:
            break
        }
    }
    
    func getOrAddVariable(
        name: String,
        defaultValue: Bool,
        title: String? = nil
    ) -> Variable<Bool> {
        
        guard let variable = variables.first(where: { $0.name == name }) else {
            let variable = Variable<Bool>(name, defaultValue, title: title)
            variables.append(variable)
            return variable
        }
        return variable
    }
    
    // CustomVariableNameProvider
     var numCustomVariables: Int {
        return variables.count
     }
     
     var customVariableNames: [String] {
        return Array(variables.map { $0.name })
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
