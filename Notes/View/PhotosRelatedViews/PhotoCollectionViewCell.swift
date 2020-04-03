//
//  PhotoCollectionViewCell.swift
//  Notes
//
//  Created by Alexander Dudin on 10/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    var isEditing: Bool = false {
        didSet {
            selectionImageView.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                selectionImageView.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
