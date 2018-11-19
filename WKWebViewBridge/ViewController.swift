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

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView?
    var changeColorButton: UIButton?
    var applePayController: PKPaymentAuthorizationViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up a message handler to receive data from Web Checkout JS
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "webCheckout")
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
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        applePayController?.dismiss(animated: true, completion: nil)
        
        let data: [String : String] = [
            "applePayToken": "example-token-123"
        ]
        let encoder = JSONEncoder()
        let jsonObject = try! encoder.encode(data)
        let payload = String(data: jsonObject, encoding: .utf8)!
        webView?.evaluateJavaScript("window.poqWebCheckout.postMessage('paymentauthorized', '" + payload + "')", completionHandler: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! String
        
        guard let data = body.data(using: .utf8),
            let payload = try? JSONDecoder().decode(WebCheckoutPayload.self, from: data) else {
            print("Error: Couldn't decode Payload from Web Checkout JS")
            return
        }
        
        switch(payload.name) {
        case "setorder":
            print("Order updated")
            print(payload.data)
        case "applepay":
            print("User requested to pay via Apple Pay")
            
            let cartTotal: NSDecimalNumber = 33.3
            
            let request = PKPaymentRequest()
            // Use the correct currency code here
            request.countryCode = "US"
            request.currencyCode = "GBP"
            request.paymentSummaryItems = [
                // Label should be the name of the merchant
                PKPaymentSummaryItem(label: "Poq", amount: cartTotal)
            ]
            request.supportedNetworks = [PKPaymentNetwork.amex]
            request.merchantCapabilities = PKMerchantCapability.capability3DS
            // Replace with the merchant's identifier
            request.merchantIdentifier = "merchant.com.poqstudio.WKWebViewBridge"
            applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            applePayController?.delegate = self
            self.present(applePayController!, animated: true, completion: nil)
        case "closewebview":
            print("Close the Web View")
        default:
            print("Error: Unknown event " + message.name + " from Web Checkout JS")
        }
    }
}
