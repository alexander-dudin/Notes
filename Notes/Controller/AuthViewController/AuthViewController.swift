//
//  AuthViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import Foundation
import WebKit
import CocoaLumberjack

final class AuthViewController: UIViewController {
    
    //MARK: Stored Properties
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let authService = AuthService()
    private let webView = WKWebView()
    private var clientID: String?
    private var clientSecret: String?
    private var code = ""
    
    //MARK: Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()        
        
        if let authService = authService {
            self.clientID = authService.clientID
            self.clientSecret = authService.clientSecret
        }
        
        guard let codeRequest = codeGetRequest else { return }
        webView.load(codeRequest)
        webView.navigationDelegate = self
    }
    
    private func setupViews() {        
        view.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: Networking. Creating and Sending URLRequests
    
    private var codeGetRequest: URLRequest? {
        if let clientID = clientID {
            guard var urlComponents = URLComponents(string: "https://github.com/login/oauth/authorize") else { return nil }
            
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: "\(clientID)"),
                URLQueryItem(name: "scope", value: "gist")
            ]
            guard let url = urlComponents.url else { return nil }
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    private var tokenPostRequest: URLRequest? {
        if let clientID = clientID, let clientSecret = clientSecret {
            let postRequestString = "https://github.com/login/oauth/access_token"
            var urlComponents = URLComponents(string: postRequestString)
            urlComponents?.queryItems = [
                URLQueryItem(name: "client_id", value: "\(clientID)"),
                URLQueryItem(name: "client_secret", value: "\(clientSecret)"),
                URLQueryItem(name: "code", value: "\(code)")
            ]
            
            if let urlComponents = urlComponents {
                if let postRequestURL = urlComponents.url {
                    var postRequest = URLRequest(url: postRequestURL)
                    postRequest.httpMethod = "POST"
                    return postRequest
                } else {
                    DDLogError("AuthViewController: postRequestURL = nil")
                    return nil
                }
            } else {
                DDLogError("AuthViewController: urlComponents = nil")
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func getToken(withPostRequest request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DDLogError("AuthViewController - getToken. Error: \(error?.localizedDescription ?? "no description")")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Successful tokenRequest. Status: \(response.statusCode)")
                default:
                    print("Token request status: \(response.statusCode)")
                }
            }
            
            if let data = data {
                guard let dataString = String(data: data, encoding: .utf8) else {
                    print("No dataString in tokenrequest")
                    return
                }
                let splitedData = dataString.split(separator: "&")
                let tokenRelatedSubstrings = splitedData.filter {$0 .contains("access_token")}
                let tokenRelatedSubstringSplited = tokenRelatedSubstrings[0].split(separator: "=")
                let token = String(tokenRelatedSubstringSplited[1])
                
                self.delegate?.handleTokenChanged(token: token)
            }
        }
        task.resume()
    }
}

//MARK: Extension: WKNavigationDelegate

extension AuthViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, let clientID = clientID, let clientSecret = clientSecret {
            defer { decisionHandler(.allow) }
            let targetString = url.absoluteString
            guard let components = URLComponents(string: targetString) else { return }
            
            if let receivedCode = components.queryItems?.first(where: { $0.name == "code" })?.value {
                code = receivedCode
                let postRequestString = "https://github.com/login/oauth/access_token"
                var urlComponents = URLComponents(string: postRequestString)
                urlComponents?.queryItems = [
                    URLQueryItem(name: "client_id", value: "\(clientID)"),
                    URLQueryItem(name: "client_secret", value: "\(clientSecret)"),
                    URLQueryItem(name: "code", value: "\(code)")
                ]
                
                guard let postRequestURL = urlComponents?.url else { return  }
                var postRequest = URLRequest(url: postRequestURL)
                postRequest.httpMethod = "POST"
                getToken(withPostRequest: postRequest)
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
