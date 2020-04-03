//
//  SaveNotesBackendOperation.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation
import CocoaLumberjack

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: BackendOperationResult?
    let authService: AuthService
    
    init(notebook: FileNotebook, authService: AuthService) {
        self.authService = authService
        super.init(notebook: notebook)
    }
    
    private func listAllGists(authService: AuthService, gistsCompletionHandler: @escaping (String?, Error?) -> Void) {

        guard let request = authService.createGetRequest() else { return }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.result = .failure(.unreachable)
                DDLogError("SaveNotesBackendOperation - listAllGists(). Error: \(error?.localizedDescription ?? "no description")")
                self.finish()
                return
            }
            
            if let response = response as? HTTPURLResponse {
                DDLogInfo("listAllGistsDataTask request status: \(response.statusCode)")
            }
            
            guard let data = data else {
                DDLogInfo("SaveNotesBackendOperation: no data in listAllGists")
                self.finish()
                return
            }
           
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let gists = try? decoder.decode([Gist].self, from: data) else {
                DDLogError("SaveNotesBackendOperation - listAllGists(). Error: failed decoding gists")
                self.finish()
                return
            }
            var fileID : String?
            for gist in gists {
                if gist.files.contains(
                    where: { (key, value) -> Bool in
                        key == "ios-course-notes-db.json" }) {
                    fileID = gist.id
                }
            }
            gistsCompletionHandler(fileID, nil)
        }
        task.resume()
    }
    
    private func packNotes(notes: [Note]) -> Data? {
        var notebookDictionary = [[String : Any]]()
        for note in notes {
            let dictionaryNote = note.json
            notebookDictionary.append(dictionaryNote)
        }
        
        guard let notebookData = try? JSONSerialization.data(
            withJSONObject: notebookDictionary, options: []
            ) else { return nil }
        guard let contentString = String(data: notebookData, encoding: .ascii) else { return nil }
        let content = GistContent(content: contentString)
        let notConvertedFiles = GistFormatNotebook(files: ["ios-course-notes-db.json" : content])
        
        guard let files = try? JSONEncoder().encode(notConvertedFiles) else { return nil }
        return files
    }
    
    private func createNewGist(authService: AuthService, notes: [Note]) -> URLSessionDataTask? {
        guard let file = packNotes(notes: notes) else { return nil }
        
        guard let postRequest = authService.createPostRequest(httpBody: file) else { return nil }
        
        let task = URLSession.shared.dataTask(with: postRequest) {(data, response, error) in
            defer { self.finish() }
            
            guard error == nil else {
                self.result = .failure(.unreachable)
                DDLogError("SaveNotesBackendOperation - createNewGist(). Error: \(error?.localizedDescription ?? "no description")")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    self.result = .success
                case 400..<600:
                    self.result = .failure(.unreachable)
                default:
                    DDLogInfo("createNewGist requestStatus: \(response.statusCode)")
                }
            }
        }
        return task
    }
    
    private func editGist(authService: AuthService, gistID: String, notes: [Note]) -> URLSessionDataTask? {

        guard let file = packNotes(notes: notes) else { return nil }
        guard let patchRequest = authService.createPatchRequest(urlString: gistID, httpBody: file) else { return nil }
        
        let task = URLSession.shared.dataTask(with: patchRequest) {(data, response, error) in
            defer { self.finish() }
            
            guard error == nil else {
                self.result = .failure(.unreachable)
                DDLogError("SaveNotesBackendOperation - editGist(). Error: \(error?.localizedDescription ?? "no description")")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    self.result = .success
                case 400..<600:
                    DDLogError("SaveNotesBackendOperation - editGist(). Error in switch.response: \(response.statusCode)")
                    self.result = .failure(.unreachable)
                default:
                    DDLogInfo("editGist  requestStatus: \(response.statusCode)")                    
                }
            }
        }
        return task
    }
    
    override func main() {
        listAllGists(authService: authService) {
            gistID, error in
            if let gistID = gistID {
                let task = self.editGist(
                    authService: self.authService,
                    gistID: gistID,
                    notes: self.notebook.notes)
                task?.resume()
            } else {
                let task = self.createNewGist(authService: self.authService, notes: self.notebook.notes)
                task?.resume()
            }
        }
    }
}
