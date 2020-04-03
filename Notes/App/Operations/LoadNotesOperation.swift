//
//  LoadNotesOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

class LoadNotesOperation: AsyncOperation {
    private let dbQueue: OperationQueue
    private let backendQueue: OperationQueue
    private var notebookFromDB = FileNotebook()
    private var notebookFromBackend = FileNotebook()
    private let loadFromDB: LoadNoteDBOperation
    private let loadFromBackend: LoadNotesBackendOperation
    private let authService: AuthService
    
    private(set) var loadedNotebook: FileNotebook?
    
    private(set) var result: Bool? = false
    
    init(dbQueue: OperationQueue, backendQueue: OperationQueue, authService: AuthService) {
        self.dbQueue = dbQueue
        self.backendQueue = backendQueue
        self.loadFromDB = LoadNoteDBOperation(notebook: notebookFromDB)
        self.loadFromBackend = LoadNotesBackendOperation(notebook: notebookFromBackend, authService: authService)
        self.authService = authService
        super.init()
    }
    
    
    override func main() {
        loadFromDB.completionBlock = {
            guard let loadedNotebook = self.loadFromDB.loadedNotebook else { return }
            self.notebookFromDB = loadedNotebook
        }
        
        loadFromBackend.completionBlock = {
            guard let loadedNotebook = self.loadFromBackend.loadedNotebook else { return }
            self.notebookFromBackend = loadedNotebook
        }
        
        let consolidatingOperation = BlockOperation {
            let finalNotebook = self.compareNotebooks(notebookFromDB: self.notebookFromDB, notebookFromBackend: self.notebookFromBackend)
            self.loadedNotebook = finalNotebook
        }
        
        consolidatingOperation.completionBlock = {
            self.result = true
            self.finish()
        }
        
        consolidatingOperation.addDependency(loadFromBackend)
        consolidatingOperation.addDependency(loadFromDB)
        
        dbQueue.addOperations([loadFromBackend, loadFromDB, consolidatingOperation], waitUntilFinished: false)
    }
 
    func compareNotebooks(notebookFromDB bdNotebook: FileNotebook, notebookFromBackend backendNotebook: FileNotebook) -> FileNotebook {
        if backendNotebook.updatedAt > bdNotebook.updatedAt {
            return backendNotebook
        } else if backendNotebook.updatedAt < bdNotebook.updatedAt {           
            return bdNotebook
        } else {
            return backendNotebook
        }
    }
}
