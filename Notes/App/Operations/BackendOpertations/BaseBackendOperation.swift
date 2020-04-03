//
//  BaseBackendOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

enum NetworkError {
    case unreachable
}

enum BackendOperationResult {
    case success
    case failure(NetworkError)
}

class BaseBackendOperation: AsyncOperation {
    let notebook: FileNotebook
    
    init(notebook: FileNotebook) {
        self.notebook = notebook
        super.init()
    }
}
