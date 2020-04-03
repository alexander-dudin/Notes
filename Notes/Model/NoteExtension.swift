//
//  NoteExtension.swift
//  Notes
//
//  Created by Alexander Dudin on 23/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

extension Note {
    var json: [String: Any] {
        get {
            var jsonDict = [String: Any]()
            jsonDict["uid"] = uid
            jsonDict["title"] = title
            jsonDict["content"] = content
            
            if color != UIColor.white {
                jsonDict["color"] = CIColor(color: self.color).stringRepresentation
            }
            
            if importance != .defaultPriority {
                jsonDict["importance"] = importance.rawValue
            }
            
            if let selfDestructionDay = selfDestructionDay {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                jsonDict["selfDestructionDay"] = dateFormatter.string(from: selfDestructionDay)
            }
            return jsonDict
        }
    }
    
    static func parse(json: [String: Any]) -> Note? {
        
        guard let parsedUid = json["uid"] else { return nil }
        let finalUid = String(describing: parsedUid)
                
        guard let parsedTitle = json["title"] else { return nil }
        let finalTitle = String(describing: parsedTitle)
        
        guard let parsedContent = json["content"] else { return nil }
        let finalContent = String(describing: parsedContent)
        
        var finalColor: UIColor = UIColor.white
        if let parsedColor = json["color"] {
            let stringColor = String(describing: parsedColor)
            finalColor = UIColor(ciColor: CIColor(string: stringColor))
        }
        
        var finalImportance: Importance = .defaultPriority
        if let parsedImportance = json["importance"] {
            if let stringImportance = Importance(rawValue: String(describing: parsedImportance)) {
                finalImportance = stringImportance
            }
        }
        
        var finalSelfDestructDate: Date? = nil
        if let parsedselfDestructionDay = json["selfDestructionDay"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let day = dateFormatter.date(from: parsedselfDestructionDay) {
                finalSelfDestructDate = day
            }
        }
        
        let outputNote = Note(
            uid: finalUid,
            title: finalTitle,
            content: finalContent,
            color: finalColor,
            importance: finalImportance,
            selfDestructionDay: finalSelfDestructDate
        )
        return outputNote
    }
}

extension Note: Equatable {
    static func == (lhs: Note, rhs: Note) -> Bool {
        return
            lhs.uid == rhs.uid &&
                lhs.title == rhs.title &&
                lhs.content == rhs.content &&
                lhs.color == rhs.color &&
                lhs.importance == rhs.importance &&
                lhs.selfDestructionDay == rhs.selfDestructionDay
    }
}
