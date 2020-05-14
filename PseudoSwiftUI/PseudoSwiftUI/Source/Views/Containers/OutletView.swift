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
    
    init(frame: CGRect, direction: VariableDirection, index: Int, name: String?) {
        let startY = connectionTopMargin + connectionMargin + CGFloat(index) * Container.inputOutputWidth + connectionMargin * CGFloat(index)
        
        switch direction {
        case .input:
            self.inlet = UIView(frame: CGRect(x: connectionMargin, y: startY, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: 40, y: startY, width: 120, height: 20))
            inlet.backgroundColor = inputInletBackgroundColor
        case .output:
            self.inlet = UIView(frame: CGRect(x: 300 - connectionMargin - 20, y: startY, width: 20, height: 20))
            self.label = UILabel(frame: CGRect(x: 120, y: startY, width: 140, height: 20))
            self.label.textAlignment = .right
            inlet.backgroundColor = outputInletBackgroundColor
        }
        
        self.label.textColor = UIColor(white: 0.85, alpha: 1)
        self.label.font = .systemFont(ofSize: 13)
        self.inlet.layer.cornerRadius = Container.connectionCornerRadius

        super.init(frame: frame)
        label.text = name
        self.addSubview(label)
        self.addSubview(inlet)
        self.isUserInteractionEnabled = true
        self.inlet.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        inlet.addGestureRecognizer(gestureRecognizer)
    }
}
