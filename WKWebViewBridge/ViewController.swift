//
//  ViewController.swift
//  WKWebViewBridge
//
//  Created by Manuel Marcos Regalado on 14/11/2018.
//  Copyright © 2018 Poq Studio Ltd. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView?
    var changeColorButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up for call backs from web
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "poqAppCallBackFromWeb")
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        
        
        // Set up call to web
        var userScript = WKUserScript(source: "setupApplePayButton()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        
        
        // Webview setup
        webView = WKWebView(frame: self.view.frame, configuration: webViewConfiguration)
        view.addSubview(webView!)
        webView?.navigationDelegate = self
        
        // Load the website
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView?.loadFileURL(url, allowingReadAccessTo: url)
        
        // Add Native button
        changeColorButton = UIButton()
        if let button = changeColorButton {
            button.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(button)
            button.setTitle("Change Web Button Color", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
    }

    // MARK: - WKScriptMessageHandler
    
    // Handles the call backs from the web
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let body = message.body as? String else {
            return
        }
        
        let alert = UIAlertController(title: "Message From Web", message: body.removingPercentEncoding, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    @IBAction func changeColorButtonTapped(_ sender: Any) {
        
    }
}
