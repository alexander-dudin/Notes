//
//  LoadNotesDBOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//


import Foundation

class LoadNoteDBOperation: BaseDBOperation {
    
    var loadedNotebook: FileNotebook? {
        return notebook
    }
    
    override init(notebook: FileNotebook) {
        super.init(notebook: notebook)
        
    }
            
    override func main() {
        notebook.loadFromFile()
        self.finish()
    }
}
