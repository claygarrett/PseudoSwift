//
//  Container.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 4/21/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit
import PseudoSwift



// MARK: - Container

struct ContainerType {
    let input: SupportedType?
    let ouptut: SupportedType?
    let variables: [VariablePlaceholder]
}

protocol Containing: AnyObject {
    func draw()
}

public class FlowContainer: Container {
    // TODO: Genericize
    var inputFlowOutlet: FlowOutlet<Bool>? = nil
    var outputFlowOutlet: FlowOutlet<Bool>? = nil
    
    var flowOutlets: [FlowOutlet<Bool>] {
        return self.boolOutlets.compactMap { (outlet) -> FlowOutlet<Bool>? in
            return outlet as? FlowOutlet
        }
    }
    var nextContainer: FlowContainer? {
        return outputFlowOutlet?.wire?.destinationOutlet?.container as? FlowContainer
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeFlowOutlets()
    }
    
    private func initializeFlowOutlets() {
        
        if !self.isFlowConductor { return }
        
        let inputFlowOutlet = FlowOutlet<Bool>(direction: .input, index: 0, frame: containerFrame, container: self)
        self.inputFlowOutlet = inputFlowOutlet
        
        let outputFlowOutlet = FlowOutlet<Bool>(direction: .output, index: 0, frame: containerFrame, container: self)
        self.outputFlowOutlet = outputFlowOutlet
        
        // draw our flow oulets
        
        self.view.addSubview(inputFlowOutlet.view)
        let inputDragGesture = UIPanGestureRecognizer(target: self, action: #selector(doValueOutletDrag))
        dragGestures.append(inputDragGesture)
        inputFlowOutlet.view.addGestureRecognizer(inputDragGesture)
        
        self.view.addSubview(outputFlowOutlet.view)
        let outputDragGesture = UIPanGestureRecognizer(target: self, action: #selector(doValueOutletDrag))
        dragGestures.append(outputDragGesture)
        outputFlowOutlet.view.addGestureRecognizer(outputDragGesture)
        
    }
    
    // TODO: Find a way to not duplicate code here if possible.
    // This is a duplicate of the main container doContainerDrag but adds additional calls for input/outputFlowOutlets
    // Same for doValueOutletDrag
    @objc public override func doContainerDrag(_ recognizer: UIPanGestureRecognizer) {
        
        guard let draggedView = recognizer.view else { return }
        
        if originBeforeDrag == nil {
            originBeforeDrag = draggedView.frame.origin
        }
        
        guard let originBeforeDrag = originBeforeDrag else {
            return
        }
        
        let existingSize: CGSize = draggedView.frame.size
        
        let translationInView = recognizer.translation(in: view.superview)
        
        let newOrigin = originBeforeDrag.movedBy(translationPoint: translationInView)
        draggedView.frame = CGRect(origin: newOrigin , size: existingSize)
        
        let xPercent = newOrigin.x / self.view!.superview!.frame.size.width
        let yPercent = newOrigin.y / self.view!.superview!.frame.size.height
        
        positionPercentage = CGPoint(x: xPercent, y: yPercent)
        
        switch recognizer.state {
        case .began:
            for outlet in self.boolValueOutlets {
                switch outlet {
                case let input as InputValueOutlet<Bool>:
                    input.wire?.outletPositionMoveStarted(outlet: input)
                case let output as OutputValueOutlet<Bool>:
                    for wire in output.wires {
                        wire.outletPositionMoveStarted(outlet: outlet)
                    }
                default:
                    continue
                }
            }
            
            if let inputOutlet = inputFlowOutlet {
                inputOutlet.wire?.outletPositionMoveStarted(outlet: inputOutlet)
            }
            
            if let outputFlow = outputFlowOutlet {
                outputFlow.wire?.outletPositionMoveStarted(outlet: outputFlow)
            }
            
            
            
        case .ended:
            self.originBeforeDrag = nil
        default:
            break
        }
        
        for outlet in self.boolValueOutlets {
            switch outlet {
            case let input as InputValueOutlet<Bool>:
                input.wire?.outletPositionMoved(outlet: input, position: translationInView)
            case let output as OutputValueOutlet<Bool>:
                for wire in output.wires {
                    wire.outletPositionMoved(outlet: output, position: translationInView)
                }
            default:
                continue
            }
        }
        
        // todo: Make these (and all similar calls) not have to go through wire since we're getting the wire from outlet and also passing in outlet
        
        if let inputOutlet = inputFlowOutlet {
            inputOutlet.wire?.outletPositionMoved(outlet: inputOutlet, position: translationInView)
        }
        
        if let outputFlow = outputFlowOutlet {
            outputFlow.wire?.outletPositionMoved(outlet: outputFlow, position: translationInView)
        }
    }
    
    @objc override public func doValueOutletDrag(_ recognizer:UIPanGestureRecognizer) {
           guard let draggedView = recognizer.view else {
               return
           }
           
           let outlet: Outlet<Bool>
           if let valueOutlet = boolOutlets.compactMap({ $0 as? ValueOutlet }).first(where: { $0.view === draggedView }) {
               // we're dragging a value outlet
               outlet = valueOutlet
           } else if let flowOutlet = inputFlowOutlet, flowOutlet.view === draggedView {
               // we're dragging a flow outlet
               outlet = flowOutlet
           } else if let flowOutlet = outputFlowOutlet, flowOutlet.view === draggedView {
           // we're dragging a flow outlet
                outlet = flowOutlet
           } else {
               return
           }
           
           let offsetFromOriginalPosition = recognizer.translation(in: self.view)
           let positionOfDraggedoutlet = draggedView.frame
           print("positionOfDraggedoutlet", positionOfDraggedoutlet)
           
           let positionInContainer = offsetFromOriginalPosition
               .movedBy(translationPoint: positionOfDraggedoutlet.origin)
               .movedBy(translationPoint: CGPoint(
                   x: startDragOffsetFromOrigin.x,
                   y: startDragOffsetFromOrigin.y
               ))
           
           let dragOrigin = draggedView.frame.origin.movedBy(vector: CGVector(dx: 10, dy: 10))
           let dragDestination = draggedView.frame.origin
               .movedBy(translationPoint: recognizer.translation(in: self.view))
               .movedBy(translationPoint: CGPoint(
                   x: startDragOffsetFromOrigin.x,
                   y: startDragOffsetFromOrigin.y)
           )
           
           switch recognizer.state {
           case .began:
               startDragOffsetFromOrigin = recognizer.location(in: draggedView)
               self.dragDelegate?.didStartConnectionDragHandlerFromView(from: self, outlet: outlet)
           case .ended:
               self.dragDelegate?.didEndConnectionDragHandlerFromView(from: self, fromOutlet: outlet, toEndPosition: dragDestination)
           default:
               break
           }
           self.dragDelegate?.didDragConnectionHandlerFromView(
               from: self,
               atPosition: dragOrigin, to: positionInContainer)
       }
}

public class Container: UIViewController, Containing {
    
    var boolOutlets: [Outlet<Bool>] = []
    
    var boolValueOutlets: [ValueOutlet<Bool>] {
        return self.boolOutlets.compactMap { (outlet) -> ValueOutlet<Bool>? in
            return outlet as? ValueOutlet
        }
    }
    
    var boolValueInputOutlets: [InputValueOutlet<Bool>] {
        return boolValueOutlets.compactMap { $0 as? InputValueOutlet<Bool> }
    }
    
    static let inputOutputWidth: CGFloat = 20
    static var connectionCornerRadius: CGFloat { return inputOutputWidth / 2 }
    let containerCornerRadius: CGFloat = 10
    var positionPercentage: CGPoint
    var dragGestures: [UIPanGestureRecognizer] = []
    weak var dragDelegate: ConnectionDragHandler?
    static var connectionRadius: CGFloat { inputOutputWidth / 2 }
    var startDragOffsetFromOrigin: CGPoint = .zero
    var containerDragGesture: UIPanGestureRecognizer!
    var originBeforeDrag: CGPoint?
    let name: String
    let typeLabel: UILabel = UILabel()
    let containerFrame = CGRect(x: 0, y: 0, width: Container.containerWidth, height: Container.containerHeight)
    
    
    static let containerWidth: CGFloat = 300
    static let containerHeight: CGFloat = 200
    
    // does the program flow through this node?
    let isFlowConductor: Bool
    
    init(positionPercentage: CGPoint, name: String, isFlowConductor: Bool) {
        self.positionPercentage = positionPercentage
        self.name = name
        self.isFlowConductor = isFlowConductor
        
        super.init(nibName: nil, bundle: nil)
        
        containerDragGesture = UIPanGestureRecognizer(target: self, action: #selector(doContainerDrag))
    }
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View / Layout
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initializeOutlets()
        // initializeTypeLabel()
        styleContainerView()
        
        view.addGestureRecognizer(containerDragGesture)
        
        draw()
    }
    
    func draw() {
        // no-op for base class case
    }
    
    func initializeTypeLabel() {
        typeLabel.text = "BoolAnd"
        typeLabel.frame = CGRect(x: 40, y: 10, width: 120, height: 20)
        typeLabel.textColor = .systemPink
        self.view.addSubview(typeLabel)
    }
    
    private func initializeOutlets() {
        initializeValueOutlets()
    }
    
    
    
    private func initializeValueOutlets() {
        // draw our value oulets
        // TODO: rename these to DattaOutlets
        let inputOutlets = boolOutlets.filter( { $0.direction == .input })
        for inputOutlet in inputOutlets {
            self.view.addSubview(inputOutlet.view)
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(doValueOutletDrag))
            dragGestures.append(dragGesture)
            inputOutlet.view.addGestureRecognizer(dragGesture)
        }
        
        let outputOutlets = boolOutlets.filter( { $0.direction == .output })
        for outputOutlet in outputOutlets {
            self.view.addSubview(outputOutlet.view)
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(doValueOutletDrag))
            dragGestures.append(dragGesture)
            outputOutlet.view.addGestureRecognizer(dragGesture)
        }
        
        view.isUserInteractionEnabled = true
    }
    
    func styleContainerView() {
        view.backgroundColor = UIColor.withHexValue(hex: "23293D")
        view.layer.cornerRadius = containerCornerRadius
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 8
    }
    
    // MARK: - Dragging
    
    @objc public func doValueOutletDrag(_ recognizer:UIPanGestureRecognizer) {
        guard let draggedView = recognizer.view else {
            return
        }
        
        let outlet: Outlet<Bool>
        if let valueOutlet = boolOutlets.compactMap({ $0 as? ValueOutlet }).first(where: { $0.view === draggedView }) {
            // we're dragging a value outlet
            outlet = valueOutlet
        } else if let flowOutlet = boolOutlets.compactMap({ $0 as? FlowOutlet }).first(where: { $0.view === draggedView }) {
            // we're dragging a flow outlet
            outlet = flowOutlet
        } else {
            return
        }
        
        let offsetFromOriginalPosition = recognizer.translation(in: self.view)
        let positionOfDraggedoutlet = draggedView.frame
        print("positionOfDraggedoutlet", positionOfDraggedoutlet)
        
        let positionInContainer = offsetFromOriginalPosition
            .movedBy(translationPoint: positionOfDraggedoutlet.origin)
            .movedBy(translationPoint: CGPoint(
                x: startDragOffsetFromOrigin.x,
                y: startDragOffsetFromOrigin.y
            ))
        
        let dragOrigin = draggedView.frame.origin.movedBy(vector: CGVector(dx: 10, dy: 10))
        let dragDestination = draggedView.frame.origin
            .movedBy(translationPoint: recognizer.translation(in: self.view))
            .movedBy(translationPoint: CGPoint(
                x: startDragOffsetFromOrigin.x,
                y: startDragOffsetFromOrigin.y)
        )
        
        switch recognizer.state {
        case .began:
            startDragOffsetFromOrigin = recognizer.location(in: draggedView)
            self.dragDelegate?.didStartConnectionDragHandlerFromView(from: self, outlet: outlet)
        case .ended:
            self.dragDelegate?.didEndConnectionDragHandlerFromView(from: self, fromOutlet: outlet, toEndPosition: dragDestination)
        default:
            break
        }
        self.dragDelegate?.didDragConnectionHandlerFromView(
            from: self,
            atPosition: dragOrigin, to: positionInContainer)
    }
    
    @objc public func doContainerDrag(_ recognizer:UIPanGestureRecognizer) {
        guard let draggedView = recognizer.view else { return }
        
        if originBeforeDrag == nil {
            originBeforeDrag = draggedView.frame.origin
        }
        
        guard let originBeforeDrag = originBeforeDrag else {
            return
        }
        
        let existingSize: CGSize = draggedView.frame.size
        
        let translationInView = recognizer.translation(in: view.superview)
        
        let newOrigin = originBeforeDrag.movedBy(translationPoint: translationInView)
        draggedView.frame = CGRect(origin: newOrigin , size: existingSize)
        
        let xPercent = newOrigin.x / self.view!.superview!.frame.size.width
        let yPercent = newOrigin.y / self.view!.superview!.frame.size.height
        
        positionPercentage = CGPoint(x: xPercent, y: yPercent)
        
        switch recognizer.state {
        case .began:
            for outlet in self.boolValueOutlets {
                switch outlet {
                case let input as InputValueOutlet<Bool>:
                    input.wire?.outletPositionMoveStarted(outlet: input)
                case let output as OutputValueOutlet<Bool>:
                    for wire in output.wires {
                        wire.outletPositionMoveStarted(outlet: output)
                    }
                default:
                    continue
                }
            }
        case .ended:
            self.originBeforeDrag = nil
        default:
            break
        }
        
        for outlet in self.boolValueOutlets {
            switch outlet {
            case let input as InputValueOutlet<Bool>:
                input.wire?.outletPositionMoved(outlet: input, position: translationInView)
            case let output as OutputValueOutlet<Bool>:
                for wire in output.wires {
                    wire.outletPositionMoved(outlet: output, position: translationInView)
                }
            default:
                continue
            }
        }
    }
}

// MARK: - Extensions

extension UIColor {
    static func withHexValue(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

