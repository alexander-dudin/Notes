//
//  CustomColorSelectionViewControllerProtocol.swift
//  Notes
//
//  Created by Alexander Dudin on 06/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

protocol CustomColorSelectionViewControllerDelegate: class {
    func didSetColor(_ controller: CustomColorSelectionViewController, color: UIColor)
}
