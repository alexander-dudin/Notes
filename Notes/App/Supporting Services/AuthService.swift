//
//  AuthService.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit
import CocoaLumberjack

class AuthService {
    private var token = ""
    private(set) var authStringURL: String
    private(set) var clientID: String
    private(set) var clientSecret: String
    
    var tokenIsEmpty: Bool {
        return token.isEmpty
    }
    
    weak var delegate: AuthServiceDelegate?
    
    init?() {
        guard let pathToAuthStrings = Bundle.main.path(forResource: "AuthStrings", ofType: "plist") else {
            DDLogError("wrong path for authStrings in AuthService")
            return nil
        }
        
        let url = URL(fileURLWithPath: pathToAuthStrings)
        
        do {
            let authStringsData = try Data(contentsOf: url)
            let plist = try PropertyListSerialization.propertyList(from: authStringsData, options: [], format: .none)
            
            if let authStrings = plist as? [String : String] {
                guard let clientID = authStrings["clientID"],
                    let authStringURL = authStrings["authStringURL"],
                    let clientSecret = authStrings["clientSecret"]
                    else {
                        DDLogError("wrong data in AuthStrings.plist in AuthService init()")
                        return nil
                }
                
                self.clientID = clientID
                self.authStringURL = authStringURL
                self.clientSecret = clientSecret
            }
            else {
                DDLogError("wrong data in AuthStrings.plist in AuthService init()")
                return nil
            }
        } catch {
            DDLogError("something wrong with Data in AuthService init()")
            return nil
        }
    }
    
    func requestToken(viewController: UIViewController) {
        let requestTokenViewController = AuthViewController()
        requestTokenViewController.delegate = self
        viewController.present(requestTokenViewController, animated: false, completion: nil)
    }
    
//MARK: HTTP Requests Methods
    
    func createGetRequest(stringURL: String = "https://api.github.com/gists") -> URLRequest? {
        guard let url = URL(string: stringURL) else { return nil }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func createPostRequest(httpBody: Data?) -> URLRequest? {
        guard var request = createGetRequest() else { return nil }
        request.httpMethod = "POST"
        request.httpBody = httpBody
        return request
    }
    
    func createPatchRequest(urlString: String, httpBody: Data?) -> URLRequest? {
        let finalUrlString = authStringURL + "/" + urlString
        guard var request = createGetRequest(stringURL: finalUrlString) else { return nil }
        request.httpMethod = "PATCH"
        request.httpBody = httpBody
        return request
    }
}

//MARK: Extension - AuthViewControllerDelegate

extension AuthService: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.token = token
        self.delegate?.requestUpdate()
    }
}
