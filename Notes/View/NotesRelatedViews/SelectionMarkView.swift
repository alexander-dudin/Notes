//
//  SelectedMarkView.swift
//  Notes
//
//  Created by Alexander Dudin on 29/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

@IBDesignable
class SelectionMarkView: UIView {
    private(set) var isSelected = false {
        didSet {
            isHidden = !isSelected
        }
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: bounds)
        circlePath.stroke()
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: 0, y: rect.maxY / 2))
        checkmarkPath.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY))
        checkmarkPath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        checkmarkPath.stroke()
    }
    
    func configureSelection() {
        isSelected = !isSelected
    }
    
    func deselect() {
        isSelected = false
    }
}
