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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up for call backs from web
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "poqAppCallBackFromWeb")
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        
        
        // Webview setup
        webView = WKWebView(frame: self.view.frame, configuration: webViewConfiguration)
        view.addSubview(webView!)
        webView?.navigationDelegate = self
        
        // Load the website
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView?.loadFileURL(url, allowingReadAccessTo: url)
   
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
    
}

