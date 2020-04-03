//
//  NoteDetailViewControllerDelegateProtocol.swift
//  Notes
//
//  Created by Alexander Dudin on 05/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

protocol NoteDetailViewControllerDelegate: class {
    
    func noteDetailViewControllerDidCancel(_ controller: NoteDetailViewController)
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishAdding note: Note)
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishEditing note: Note)
}
