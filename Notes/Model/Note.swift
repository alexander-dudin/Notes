//
//  Note.swift
//  Notes
//
//  Created by Alexander Dudin on 23/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

enum Importance: String {
    case lowPriority
    case defaultPriority
    case highPriority
}

struct Note {
    var uid: String
    let title: String
    let content: String
    var color: UIColor
    let importance: Importance
    let selfDestructionDay: Date?
    
    init(uid: String  = UUID().uuidString, title: String, content: String, color: UIColor  = UIColor.white, importance: Importance, selfDestructionDay: Date? = nil) {
        self.uid = uid
        self.title = title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructionDay = selfDestructionDay
    }
}
