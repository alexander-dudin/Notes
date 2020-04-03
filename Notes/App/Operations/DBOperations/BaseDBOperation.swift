//
//  BaseDBOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 14/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

class BaseDBOperation: AsyncOperation {
    let notebook: FileNotebook
    
    init(notebook: FileNotebook) {
        self.notebook = notebook
        super.init()
    }
}
