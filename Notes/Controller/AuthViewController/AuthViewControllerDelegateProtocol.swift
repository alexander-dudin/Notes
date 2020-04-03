//
//  AuthViewControllerDelegateProtocol.swift
//  Notes
//
//  Created by Alexander Dudin on 14/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

protocol AuthViewControllerDelegate: class {
    func handleTokenChanged(token: String)
}
