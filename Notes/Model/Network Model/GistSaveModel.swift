//
//  GistSaveModel.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation

struct GistFormatNotebook: Codable {
    let files: [String : GistContent]
    let `public` = false
}

struct GistContent: Codable {
    let content: String
}
