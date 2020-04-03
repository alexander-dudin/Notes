//
//  LoadNotesBackendOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation
import CocoaLumberjack

class LoadNotesBackendOperation: BaseBackendOperation {
    var result:BackendOperationResult?
    private let authService: AuthService
    
    var loadedNotebook: FileNotebook? {
        return notebook
    }
    
    init(notebook: FileNotebook, authService: AuthService) {
        self.authService = authService
        super.init(notebook: notebook)
    }
   
    private func parseGists(gists: [Gist]) -> String? {
        var rawURL: String?
        for gist in gists {
            if gist.files.contains(
                where: { (key, value) -> Bool in
                    key == "ios-course-notes-db.json" }) {
                guard let ourNotebook = gist.files["ios-course-notes-db.json"] else { print("ourNotebook is nil"); return nil }
                rawURL = ourNotebook.rawUrl
                return rawURL
            } else {
                rawURL = nil
            }
        }
        return rawURL
    }
    
    private func getGistsDataTask(rawUrlCompletionHandler: @escaping (String?, Error?) -> Void) {
        guard let request = authService.createGetRequest() else { return }
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                DDLogError("LoadNotesBackendOperation - getGistsDataTask(). Error: \(error?.localizedDescription ?? "no description")")
                self?.result = .failure(.unreachable)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                DDLogInfo("getGistsDataTask request status: \(response.statusCode)")
            }
            
            guard let data = data, let self = self else {
                DDLogInfo("LoadNotesBackendOperation: no data getGistsDataTask")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let gists = try? decoder.decode([Gist].self, from: data) else {
                DDLogError("LoadNotesBackendOperation - getGistsDataTask(): failed decoding gists in getGistsDataTask")
                return
            }
            
            let rawURL = self.parseGists(gists: gists)
            rawUrlCompletionHandler(rawURL, error)
        }
        task.resume()
    }
    
    private func getNotebookDataTask(rawURL: String, notebook: FileNotebook) {
        guard let request = authService.createGetRequest(stringURL: rawURL) else { return }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer { self.finish() }
            guard error == nil else {
                self.result = .failure(.unreachable)
                print("LoadNotesBackendOperation - getGistsDataTask(). Error: \(error?.localizedDescription ?? "no description")")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                DDLogInfo("getNotebookDataTask request status: \(response.statusCode)")
            }
            
            guard let data = data else {
                DDLogInfo("LoadNotesBackendOperation: no data getNotebookDataTask")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let notes = try? decoder.decode([[String: String]].self, from: data) else {
                DDLogError("LoadNotesBackendOperation - getGistsDataTask(): failed decoding notes")
                return
            }
            for note in notes {
                let parsedNote = Note.parse(json: note)
                if let parsedNote = parsedNote {
                    self.notebook.add(parsedNote)
                }
            }
            self.result = .success
        }
        task.resume()
    }
    
    override func main() {
        getGistsDataTask() { url, error in
            if let rawURL = url {
                self.getNotebookDataTask(rawURL: rawURL, notebook: self.notebook)
            } else {
                DDLogError("LoadNotesBackendOperation: Couldn't get rawURL from Gists")
                self.finish()
            }
        }
    }
}
