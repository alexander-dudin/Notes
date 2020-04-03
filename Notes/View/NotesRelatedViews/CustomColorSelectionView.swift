//
//  CustomColorSelectionView.swift
//  Notes
//
//  Created by Alexander Dudin on 29/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

@IBDesignable
class CustomColorSelectionView: UIView {
    
    //MARK: Stored Properties
    
    private var hue: CGFloat = 0
    private var saturation: CGFloat = 0
    private var brightness: CGFloat = 0
    
    //MARK: IBOutlets
    
    @IBOutlet private weak var colorPreview: UIView!
    @IBOutlet private weak var hexCodeLabel: UILabel!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet private weak var slider: UISlider!
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        let sliderValue = CGFloat(sender.value)
        brightness = sliderValue
        let oldBackgroundColor = colorPreview.backgroundColor
        oldBackgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let newBackgroundColor = UIColor(hue: hue, saturation: saturation, brightness: sliderValue, alpha: alpha)
        colorPreview.backgroundColor = newBackgroundColor
        hexCodeLabel.text = toHex(color: newBackgroundColor) ?? ""
        colorPickerView.setColor(newBackgroundColor)
    }
    
    //MARK: Init & Setup View
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        let xibView = loadViewFromXib()
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
        
        colorPickerView.layer.borderWidth = 1
        colorPickerView.layer.borderColor = UIColor.gray.cgColor
        colorPreview.backgroundColor = colorPickerView.selectedColor
        guard let color = colorPreview.backgroundColor else {
            hexCodeLabel.text = ""
            return
        }
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        slider.value = Float(brightness)
        hexCodeLabel.text = toHex(color: color)
    }
    
    private func loadViewFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomColorSelectionView", bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
    
    //MARK: Main Methods
    
    func handleNewColor(newColor: UIColor) {
        colorPreview.backgroundColor = newColor
        newColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        slider.value = Float(brightness)
        hexCodeLabel.text = toHex(color: newColor) ?? ""
        colorPickerView.setColor(newColor)
        colorPickerView.refreshPointerPosition()
    }
    
    func refresh() {
        colorPickerView.refreshPointerPosition()
    }
    
    private func toHex(color: UIColor, alpha: Bool = false) -> String? {
        guard let components = color.cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return "#" + String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return "#" + String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
