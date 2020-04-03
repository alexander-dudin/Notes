//
//  SaveNoteDBOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 14/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

class SaveNoteDBOperation: BaseDBOperation {
    
    private let note: Note 
    
    init(note: Note,
         notebook: FileNotebook
    ) {
        self.note = note
      
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.add(note)
        notebook.saveToFile()
        self.finish()
    }
}
