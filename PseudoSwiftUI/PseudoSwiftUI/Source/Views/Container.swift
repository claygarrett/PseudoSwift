//
//  ContainerViewController.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 4/21/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit
import PseudoSwift


// MARK: - Connection

class Connection {
    let sourceOutlet: Outlet
    let destintationOutlet: Outlet
    let wire: Wire
    
    init(sourceOutlet: Outlet, destintationOutlet: Outlet, wire: Wire) {
        self.sourceOutlet = sourceOutlet
        self.destintationOutlet = destintationOutlet
        self.wire = wire
    }
    
    func clear() {
        self.wire.view.removeFromSuperview()
    }
}


// MARK: - Container

struct ContainerType {
    let input: SupportedType?
    let ouptut: SupportedType?
    let variables: [VariableDefinition]
}

class ContainerViewController: UIViewController {
    
    var outlets: [Outlet] = []
    static let inputOutputWidth: CGFloat = 20
    static var connectionCornerRadius: CGFloat { return inputOutputWidth / 2 }
    let containerCornerRadius: CGFloat = 10
    let connectionMargin: CGFloat = 10
    var positionPercentage: CGPoint
    var dragGestures: [UIPanGestureRecognizer] = []
    weak var dragDelegate: ConnectionDragHandler?
    static var connectionRadius: CGFloat { inputOutputWidth / 2 }
    var startDragOffsetFromOrigin: CGPoint = .zero
    var containerDragGesture: UIPanGestureRecognizer!
    var originBeforeDrag: CGPoint?
    let nameLabel: UILabel = UILabel()
    let name: String

    // MARK: - Initializers
    
    init(positionPercentage: CGPoint, inputs: [VariableDefinition] = [], output: VariableDefinition? = nil, variables: [VariableDefinition] = [], name: String) {
        
        for input in inputs {
            let inputOutlet = Outlet(type: .inputValue, inputVariable: input, view: UIView())
            outlets.append(inputOutlet)
        }
        
        if let output = output {
            let outputOutlet = Outlet(type: .outputValue, inputVariable: output, view: UIView())
            outlets.append(outputOutlet)
        }
        
        self.positionPercentage = positionPercentage
        self.name = name
        
        super.init(nibName: nil, bundle: nil)
        
        containerDragGesture = UIPanGestureRecognizer(target: self, action: #selector(doContainerDrag))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View / Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
        styleContainerView()
    }
    
    override func viewDidLayoutSubviews() {
        let viewWidth = view.frame.size.width
        let inputOutlets = outlets.filter { $0.type == OutletType.inputValue }
        let outputOutlets = outlets.filter {  $0.type == OutletType.outputValue }
        
        for (index, outlet) in outputOutlets.enumerated() {
            outlet.view.frame = CGRect(x: viewWidth - ContainerViewController.inputOutputWidth - connectionMargin, y: 50 + connectionMargin + CGFloat(index) * ContainerViewController.inputOutputWidth + connectionMargin * CGFloat(index), width: ContainerViewController.inputOutputWidth, height: ContainerViewController.inputOutputWidth)
        }
        
        for (index, outlet) in inputOutlets.enumerated() {
            outlet.view.frame = CGRect(x: connectionMargin, y: 50 + connectionMargin + CGFloat(index) * ContainerViewController.inputOutputWidth + connectionMargin * CGFloat(index), width: ContainerViewController.inputOutputWidth, height: ContainerViewController.inputOutputWidth)
        }
    }
    
    private func initializeViews() {
        
        nameLabel.text = name
        nameLabel.frame = CGRect(x: 40, y: 10, width: 120, height: 20)
        nameLabel.textColor = .white
        self.view.addSubview(nameLabel)
        
        let inputOutlets = outlets.filter( { $0.type == .inputValue })
        for (index, inputOutlet) in inputOutlets.enumerated() {
            styleInputView(forOutlet: inputOutlet)
            self.view.addSubview(inputOutlet.view)
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(doOutletDrag))
            dragGestures.append(dragGesture)
            inputOutlet.view.addGestureRecognizer(dragGesture)
        }
        
        let outputOutlets = outlets.filter( { $0.type == .outputValue })
        for outputOutlet in outputOutlets {
            styleInputView(forOutlet: outputOutlet)
            self.view.addSubview(outputOutlet.view)
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(doOutletDrag))
            dragGestures.append(dragGesture)
            outputOutlet.view.addGestureRecognizer(dragGesture)
        }
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(containerDragGesture)
    }
    
    func styleInputView(forOutlet outlet: Outlet) {
        outlet.view.layer.cornerRadius = ContainerViewController.connectionCornerRadius
        outlet.view.backgroundColor = outlet.type.backgroundColor
    }
    
    func styleOutputView(forOutlet outlet: Outlet) {
        outlet.view.layer.cornerRadius = ContainerViewController.connectionCornerRadius
        outlet.view.backgroundColor = outlet.type.backgroundColor
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
    
    @objc public func doOutletDrag(_ recognizer:UIPanGestureRecognizer) {
        guard
            let draggedView = recognizer.view,
            let outlet = outlets.first(where: { $0.view === draggedView }) else {
                return
        }
        
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
            atPosition: dragOrigin, to: dragDestination)
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
            for outlet in self.outlets {
                guard let connection = outlet.connection else { continue }
                connection.wire.outletPositionMoveStarted(outlet: outlet)
            }
            
        case .ended:
            self.originBeforeDrag = nil
        default:
            break
        }
        
        for outlet in self.outlets {
            guard let connection = outlet.connection else { continue }
            connection.wire.outletPositionMoved(outlet: outlet, position: translationInView)
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

