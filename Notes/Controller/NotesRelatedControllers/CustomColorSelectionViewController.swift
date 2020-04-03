//
//  CustomColorSelectionViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 06/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class CustomColorSelectionViewController: UIViewController {
    var delegate: CustomColorSelectionViewControllerDelegate?
    var preSelectedCustomColor: UIColor?
    
    @IBOutlet weak var customColorSelectionView: CustomColorSelectionView!
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let color = customColorSelectionView.colorPickerView.selectedColor else {
            return }
        delegate?.didSetColor(self, color: color)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customColorSelectionView.colorPickerView.onColorDidChange = {
            [weak self] color in
            DispatchQueue.main.async {
                if let self = self {
                    self.customColorSelectionView.handleNewColor(newColor: color)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let preSelectedCustomColor = preSelectedCustomColor {
            customColorSelectionView.handleNewColor(newColor: preSelectedCustomColor)
        } else {
            customColorSelectionView.refresh()
        }
    }
}
