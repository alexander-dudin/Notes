//
//  RemoveNoteOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

class RemoveNoteOperation: AsyncOperation {
    private let removeNote: RemoveNoteDBOperation
    private let saveToBackend: SaveNotesBackendOperation
    
    private let dbQueue: OperationQueue
    
    private(set) var result: Bool? = false
    
    init(note: Note,
         notebook: FileNotebook,
         dbQueue: OperationQueue,
         backendQueue: OperationQueue,
         authService: AuthService,
         deleteAnimation: @escaping (() -> Void)
    ) {
        removeNote = RemoveNoteDBOperation(note: note, notebook: notebook, deleteAnimation: deleteAnimation)
        saveToBackend = SaveNotesBackendOperation(notebook: notebook, authService: authService)
        self.dbQueue = dbQueue
        super.init()
    }
    
    override func main() {
        saveToBackend.completionBlock = {
            self.finish()
        }
        removeNote.completionBlock = {
            self.dbQueue.addOperation(self.saveToBackend)
        }
        dbQueue.addOperation(removeNote)
    }
}
