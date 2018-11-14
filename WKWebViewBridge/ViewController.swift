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
    
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webViewConfiguration = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        
        userContentController.add(self, name: "buttonTapped")
        
        //webView.configuration =
        
        webView.navigationDelegate = self
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        
        
        
    }

    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
}

