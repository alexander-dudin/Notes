//
//  UIColorExtension.swift
//  Notes
//
//  Created by Alexander Dudin on 02/04/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

extension UIColor {
    func equals(_ rhs: UIColor) -> Bool {
        var lhsR: CGFloat = 0
        var lhsG: CGFloat = 0
        var lhsB: CGFloat = 0
        var lhsA: CGFloat = 0
        self.getRed(&lhsR, green: &lhsG, blue: &lhsB, alpha: &lhsA)

        var rhsR: CGFloat = 0
        var rhsG: CGFloat = 0
        var rhsB: CGFloat = 0
        var rhsA: CGFloat = 0
        rhs.getRed(&rhsR, green: &rhsG, blue: &rhsB, alpha: &rhsA)

        return  lhsR == rhsR &&
                lhsG == rhsG &&
                lhsB == rhsB &&
                lhsA == rhsA
    }
}
