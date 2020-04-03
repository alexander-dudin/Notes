//
//  TableViewCell.swift
//  Notes
//
//  Created by Alexander Dudin on 10/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var noteColorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
