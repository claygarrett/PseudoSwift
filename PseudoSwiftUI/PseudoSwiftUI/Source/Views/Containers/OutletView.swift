//
//  OutletView.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 5/6/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit
import PseudoSwift

public class OutletView: UIView {
    
    let label: UILabel
    let inlet: UIView
    let connectionMargin: CGFloat = 10
    let connectionTopMargin: CGFloat = 40
    let inputInletBackgroundColor: UIColor = .systemPink
    let outputInletBackgroundColor: UIColor = .systemPurple
    let flowInletColor: UIColor = .green
    
    // TODO: Remove frame from instantation
    init(frame: CGRect, direction: OutletDirection, type: OutletType, index: Int, name: String?) {
        let startY = connectionTopMargin + connectionMargin + CGFloat(index) * Container.inputOutputWidth + connectionMargin * CGFloat(index)
        
        // TODO: Make output outlets draggable by name. They're currently outside the frame
        // as our math is expecting the outlet to be at the begginging of the frame.
        // Need to put output outlets on far right of frame and adjust math accordingly.
        
        let frame: CGRect
        switch (direction, type) {
        case (.input, .value):
            frame = CGRect(x: connectionMargin, y: startY, width: 180, height: 20)
            self.inlet = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: 30, y: 0, width: 120, height: 20))
            inlet.backgroundColor = inputInletBackgroundColor
        case (.output, .value):
            frame = CGRect(x: 300 - connectionMargin - 20, y: startY, width: 180, height: 20)
            self.inlet = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: -150, y: 0, width: 140, height: 20))
            self.label.textAlignment = .right
            inlet.backgroundColor = outputInletBackgroundColor
        case (.input, .flow):
            frame = CGRect(x: connectionMargin, y: startY, width: 180, height: 20)
            self.inlet = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: 30, y: 0, width: 120, height: 20))
            inlet.backgroundColor = flowInletColor
        case (.output, .flow):
            frame = CGRect(x: 300 - connectionMargin - 20, y: startY, width: 20, height: 20)
            self.inlet = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: -150, y: 0, width: 140, height: 20))
            self.label.textAlignment = .right
            inlet.backgroundColor = flowInletColor
        }
        
        self.label.textColor = UIColor(white: 0.85, alpha: 1)
        self.label.font = .systemFont(ofSize: 13)
        self.inlet.layer.cornerRadius = Container.connectionCornerRadius
        
        super.init(frame: frame)
        label.text = name
        self.addSubview(label)
        self.addSubview(inlet)
        self.isUserInteractionEnabled = true
        self.inlet.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
