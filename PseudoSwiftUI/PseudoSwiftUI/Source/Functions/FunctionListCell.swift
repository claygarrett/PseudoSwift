//
//  FunctionListCell.swift
//  PseudoSwiftUI
//
//  Created by Clayton Garrett on 5/3/20.
//  Copyright © 2020 Clayton Garrett. All rights reserved.
//

import UIKit

class FunctionListCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
