//
//  ColorPickerView.swift
//  Notes
//
//  Created by Alexander Dudin on 29/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class ColorPickerView : UIView {
    
    //MARK: Stored properties
    
    private let pointerView = PointerView()
    private(set) var selectedColor: UIColor?
    
    var onColorDidChange: ((_ color: UIColor) -> ())?
    
    private let saturationExponentTop:Float = 2.0
    private let saturationExponentBottom:Float = 1.3
 
    private let elementSize: CGFloat = 1.0
    
    //MARK: Init & Setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.clipsToBounds = true
        let touchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.touchedColor(gestureRecognizer:)))
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)
        
        pointerView.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
        pointerView.backgroundColor = .clear
        addSubview(pointerView)
        if selectedColor != nil {
            refreshPointerPosition()
        } else {
            setDefaultColor()
        }
        refreshPointerPosition()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        for y in stride(from: CGFloat(0), to: rect.height, by: elementSize) {
            
            var saturation = y < rect.height / 2.0 ? CGFloat(2 * y) / rect.height : 2.0 * CGFloat(rect.height - y) / rect.height
            saturation = CGFloat(powf(Float(saturation), y < rect.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
            let brightness = y < rect.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(rect.height - y) / rect.height
            
            for x in stride(from: (0 as CGFloat), to: rect.width, by: elementSize) {
                let hue = x / rect.width
                
                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                
                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(x:x, y: y,
                                     width: elementSize, height: elementSize))
            }
        }
    }
    
    //MARK: Methods For Working With Color
    
    private func getColorAtPoint(point: CGPoint) -> UIColor {
        let roundedPoint = CGPoint(x:elementSize * CGFloat(Int(point.x / elementSize)),
                                   y:elementSize * CGFloat(Int(point.y / elementSize)))
        
        let hue = roundedPoint.x / self.bounds.width
        
        var saturation = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(2 * roundedPoint.y) / self.bounds.height
            : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        
        saturation = CGFloat(powf(Float(saturation), roundedPoint.y < self.bounds.height / 2.0 ? saturationExponentTop : saturationExponentBottom))
        let brightness = roundedPoint.y < self.bounds.height / 2.0 ? CGFloat(1.0) : 2.0 * CGFloat(self.bounds.height - roundedPoint.y) / self.bounds.height
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
    
    private func getPointForColor(color:UIColor) -> CGPoint {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil);
        
        var yPos:CGFloat = 0
        let halfHeight = (self.bounds.height / 2)
        if (brightness >= 0.99) {
            let percentageY = powf(Float(saturation), 1.0 / saturationExponentTop)
            yPos = CGFloat(percentageY) * halfHeight
        } else {
            yPos = halfHeight + halfHeight * (1.0 - brightness)
        }
        let xPos = hue * self.bounds.width
        return CGPoint(x: xPos, y: yPos)
    }
    
    func refreshPointerPosition() {
        if let selectedColor = self.selectedColor {
            pointerView.center = getPointForColor(color: selectedColor)
        } else {
            setDefaultColor()
        }
    }
    
    func setColor(_ color: UIColor) {
          selectedColor = color
          refreshPointerPosition()
      }
    
    private func setDefaultColor() {
        let defaultColor = getColorAtPoint(point: CGPoint(x: frame.width/2, y: frame.height/2))
        setColor(defaultColor)
        pointerView.center = getPointForColor(color: defaultColor)  
    }
    
    @objc private func touchedColor(gestureRecognizer: UILongPressGestureRecognizer){
        let point = gestureRecognizer.location(in: self)
        let color = getColorAtPoint(point: point)
        selectedColor = color
        refreshPointerPosition()
        self.onColorDidChange?(color)
    }
}
