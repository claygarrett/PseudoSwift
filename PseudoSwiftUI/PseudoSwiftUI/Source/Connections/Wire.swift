//
//  Wire.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 4/22/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit


enum ConnectionPosition {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}


class Wire: UIViewController {

    @IBOutlet weak var inputConnection: UIView!
    @IBOutlet weak var outputConnection: UIView!
    
    let type: OutletType
    
    var inputCorner: ConnectionPosition = .topLeft
    var outputCorner: ConnectionPosition = .bottomRight
    
    let cornerRadius: CGFloat = 15
    let pinDiameter: CGFloat = 30
    
    var inputPosition: CGPoint? = nil
    var outputPosition: CGPoint? = nil
    
    var inputOutlet: Outlet? = nil
    var outputOutlet: Outlet? = nil
    
    var pinRadius: CGFloat {
        return pinDiameter / 2
    }
    
    var line: CAShapeLayer = CAShapeLayer()

    var color: CGColor {
        switch self.type {
        case .flow:
            return UIColor.green.cgColor
        case .value:
            return  UIColor.systemPink.cgColor
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        inputConnection.layer.cornerRadius = cornerRadius
        outputConnection.layer.cornerRadius = cornerRadius
    }
    
    init(type: OutletType, nibName: String?, bundle: Bundle?) {
        self.type = type
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func calculateLine() {
        
        guard let inputPosition = self.inputPosition, let outputPosition = self.outputPosition else {
              return
      }
        
        if inputPosition.x < outputPosition.x {
            if inputPosition.y < outputPosition.y {
                inputCorner = .topLeft
                outputCorner = .bottomRight
            } else {
                inputCorner = .bottomLeft
                outputCorner = .topRight
            }
        } else {
            if inputPosition.y < outputPosition.y {
                inputCorner = .topRight
                outputCorner = .bottomLeft
            } else {
                inputCorner = .bottomRight
                outputCorner = .topLeft
            }
        }
                
        let viewWidth = self.view.frame.size.width
        let viewHeight = self.view.frame.size.height
        
        let left: CGFloat = 0
        let top: CGFloat = 0
        let right = viewWidth
        let bottom = viewHeight
        
        let topLeftPoint = CGPoint(x: left, y: top)
        let bottomLeftPoint = CGPoint(x: left, y: bottom)
        let topRightPoint = CGPoint(x: right, y: top)
        let bottomRightPoint = CGPoint(x: right, y: bottom)
        
        let viewSize: CGSize = CGSize(width: pinDiameter, height: pinDiameter)
        
        let inputOrigin: CGPoint
        let outputOrigin: CGPoint
 
        switch inputCorner {
        case .topLeft:
            inputOrigin = topLeftPoint
            
        case .topRight:
            inputOrigin = topRightPoint
            
        case .bottomLeft:
            inputOrigin = bottomLeftPoint
            
        case .bottomRight:
            inputOrigin = bottomRightPoint
            
        }
        
        switch outputCorner {
        case .topLeft:
            outputOrigin = topLeftPoint
            
        case .topRight:
            outputOrigin = topRightPoint

        case .bottomLeft:
            outputOrigin = bottomLeftPoint
            
        case .bottomRight:
            outputOrigin = bottomRightPoint
            
        }
        
        inputConnection.frame = CGRect(origin: inputOrigin, size: viewSize)
        outputConnection.frame = CGRect(origin: outputOrigin, size: viewSize)
        
        drawLine(
            fromPoint: inputOrigin,
            toPoint: outputOrigin
        )
    }
    
    func updateWireFrame(inputHandlePosition: CGPoint, outputHandlePosition: CGPoint) {
        
        let wireFrame = CGRect(
            origin: inputHandlePosition,
            size: CGSize(
                    width: outputHandlePosition.x - inputHandlePosition.x,
                    height: outputHandlePosition.y - inputHandlePosition.y
                  )
        )
        
        self.view.frame = wireFrame
        
        self.inputPosition = outputHandlePosition
        self.outputPosition = inputHandlePosition
        
        calculateLine()
        
    }
    
    func drawLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        line.removeFromSuperlayer()
        line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.lineDashPattern = [2, 5]
        line.strokeColor = color
        line.lineWidth = 2
        line.lineJoin = CAShapeLayerLineJoin.round
        line.lineCap = .round
        self.view.layer.addSublayer(line)
        self.view.backgroundColor = UIColor.clear
    }
    
    var wireFrameWhenStarted: CGRect = .zero
    
    func outletPositionMoveStarted(outlet: Outlet) {
        wireFrameWhenStarted = self.view.frame
    }
    
    func outletPositionMoved(outlet: Outlet, position: CGPoint) {        
        guard
            let inputPosition = self.inputOutlet?.view.inlet.convert(CGPoint(x: 10, y: 10), to: self.view.superview),
            let outputPosition = self.outputOutlet?.view.inlet.convert(CGPoint(x: 10, y: 10), to: self.view.superview) else {
                return
        }
                
        let wireFrame = CGRect(
            origin: inputPosition, size:
            CGSize(
                width: outputPosition.x - inputPosition.x,
                height: outputPosition.y - inputPosition.y
            )
        )
        self.view.frame = wireFrame
        
        self.inputPosition = self.inputOutlet?.view.inlet.convert(CGPoint.zero, to: self.view.superview)
        self.outputPosition = self.outputOutlet?.view.inlet.convert(CGPoint.zero, to: self.view.superview)
        
        calculateLine()
    }
    
    func outletPositionMoveEnded(outlet: ValueOutlet, position: CGPoint) {
        
    }
}
