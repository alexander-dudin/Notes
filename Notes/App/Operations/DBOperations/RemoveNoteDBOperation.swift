//
//  RemoveNoteDBOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

class RemoveNoteDBOperation: BaseDBOperation {
    private let note: Note
    private let deleteAnimation: (() -> Void)
    
    init(note: Note, notebook: FileNotebook, deleteAnimation: @escaping (() -> Void)) {
        self.note = note
        self.deleteAnimation = deleteAnimation
        super.init(notebook: notebook)
    }
    
    override func main() {
        notebook.remove(with: note.uid)
        DispatchQueue.main.async {
            self.deleteAnimation()
        }
        self.finish()
    }
}
