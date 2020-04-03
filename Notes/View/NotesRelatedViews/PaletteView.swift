//
//  PaletteView.swift
//  Notes
//
//  Created by Alexander Dudin on 29/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class PaletteView: UIView {
    private(set) var customColorIsSelected = false
    
    func configureColorSelection() {
        customColorIsSelected = !customColorIsSelected
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        if !customColorIsSelected {
            for y : CGFloat in stride(from: 0.0 ,to: rect.height, by:  1.0) {
                var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
                saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? 2.0 : 1.3))
                let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
                for x : CGFloat in stride(from: 0.0 ,to: rect.width, by:  1.0) {
                    let hue = x / rect.width
                    let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                    context!.setFillColor(color.cgColor)
                    context!.fill(CGRect(x:x, y:y, width: 1.0,height: 1.0))
                }
            }
        } else {
            super.draw(rect)
        }
    }
}
