//
//  WebCheckoutController.swift
//  WKWebViewBridge
//
//  Created by Manuel Marcos Regalado on 14/11/2018.
//  Copyright © 2018 Poq Studio Ltd. All rights reserved.
//

import UIKit
import WebKit
import PassKit

class WebCheckoutController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView?
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
    
    func postMessage(name: String, data: [String : String]?) {
        let encoder = JSONEncoder()
        var payload = ""
        if (data != nil) {
            let jsonObject = try! encoder.encode(data)
            payload = String(data: jsonObject, encoding: .utf8)!
        }
        webView?.evaluateJavaScript("window.poqWebCheckout.postMessage('" + name + "', '" + payload + "')", completionHandler: nil)
    }
    
    func onWebCheckoutAvailable() {
        print("Web Checkout JS available")
        // Tell Web Checkout JS if Apple Pay is available
        if (PKPaymentAuthorizationViewController.canMakePayments()) {
            postMessage(name: "applepayenabled", data: nil)
        }
    }
}

extension WebCheckoutController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        let applePayToken = String(data: payment.token.paymentData, encoding: .utf8)!
        postMessage(name: "paymentauthorized", data: [
            "applePayToken": applePayToken
        ])
        
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Close the Apple Pay modal when finished
        applePayController?.dismiss(animated: true, completion: nil)
    }
}

extension WebCheckoutController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! String
        
        guard let data = body.data(using: .utf8),
            let payload = try? JSONDecoder().decode(WebCheckoutPayload.self, from: data) else {
            print("Error: Couldn't decode Payload from Web Checkout JS")
            return
        }
        
        switch(payload.name) {
        case "ping":
            // Web Checkout JS has downloaded and is running on the web
            onWebCheckoutAvailable()
        case "setorder":
            print("Order updated")
            print(payload.data)
        case "applepay":
            // User requested to pay via Apple Pay
            // Set up the cart total
            let cartTotal: NSDecimalNumber = 33.3
            
            let request = PKPaymentRequest()
            // Use the correct currency code here
            request.countryCode = "US"
            request.currencyCode = "GBP"
            request.paymentSummaryItems = [
                // Label should be the name of the merchant
                PKPaymentSummaryItem(label: "Poq", amount: cartTotal)
            ]
            // Supported payment networks
            request.supportedNetworks = [PKPaymentNetwork.amex]
            // Merchant supports 3-D Secure
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
