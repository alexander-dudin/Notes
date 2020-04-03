//
//  GistLoadModel.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

enum CodingKeys: String, CodingKey {
    case rawUrl = "raw_url"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
}

struct Gist: Codable {
    let files: [String : GistFile]
    let id: String
    let createdAt: String
    let updatedAt: String
}

struct GistFile: Codable {
    let filename: String
    let rawUrl: String
}
