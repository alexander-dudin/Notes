//
//  PointerView.swift
//  Notes
//
//  Created by Alexander Dudin on 29/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class PointerView: UIView {
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: bounds)
        circlePath.stroke()
    }
}
