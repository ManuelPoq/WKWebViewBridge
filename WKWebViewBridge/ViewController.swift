//
//  ViewController.swift
//  WKWebViewBridge
//
//  Created by Manuel Marcos Regalado on 14/11/2018.
//  Copyright © 2018 Poq Studio Ltd. All rights reserved.
//

import UIKit
import WebKit
import PassKit

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
            button.setTitle("Change Checkout Now Button Color", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action:#selector(changeColorCheckoutNowButton), for: .touchUpInside)
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

        let request = PKPaymentRequest()
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "T-shirt", amount: 33.3),
        ]
        request.supportedNetworks = [PKPaymentNetwork.amex]
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.merchantIdentifier = "merchant.com.poqstudio.WKWebViewBridge"
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        self.present(applePayController!, animated: true, completion: nil)
    }

    @objc func changeColorCheckoutNowButton() {
        webView?.evaluateJavaScript("changeColorCheckoutNowButton();", completionHandler: nil)
    }
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
    }
    

}
