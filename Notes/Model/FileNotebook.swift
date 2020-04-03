//
//  FileNotebook.swift
//  Notes
//
//  Created by Alexander Dudin on 23/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation
import CocoaLumberjack

class FileNotebook {
    private(set) var notes: [Note] = []
    private(set) var updatedAt: Date
    
    init() {
        self.updatedAt = Date()
    }
    
    public func add(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.uid == note.uid }) {
            notes[index] = note
            updatedAt = Date()
        } else {
            notes.append(note)
            updatedAt = Date()
        }
    }
    
    public func remove(with uid: String) {
        for (index, note) in notes.enumerated() {
            if note.uid == uid {
                notes.remove(at: index)
                updatedAt = Date()
            }
        }
    }
    
    public func saveToFile() {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        
        do {
            var notebook = [[String : Any]]()
            for note in notes {
                let noteData = note.json
                notebook.append(noteData)
            }
            let notebookData = try JSONSerialization.data(withJSONObject: notebook)
            if let filePath = cachesPath?.appendingPathComponent("ios-course-notes-db").appendingPathExtension("json") {
                try notebookData.write(to: filePath, options: .atomic)
            }
        } catch {
            print(error)
        }
    }
    
    public func loadFromFile() {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        do {
            if let filePath = cachesPath?.appendingPathComponent("ios-course-notes-db").appendingPathExtension("json") {
                let loadedData = try Data(contentsOf: filePath)
                guard let loadedNotebook = try JSONSerialization.jsonObject(with: loadedData) as? [[String : Any]] else { return }
                for note in loadedNotebook {
                    guard let loadedNote = Note.parse(json: note) else { return }
                    notes.append(loadedNote)
                }
            } else {
                DDLogInfo("There is no notebook on device")
            }
        } catch  {
            print(error)
        }
    }
}
