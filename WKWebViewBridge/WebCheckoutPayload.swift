//
//  WebCheckoutPayload.swift
//  WKWebViewBridge
//
//  Created by Dan Bovey on 19/11/2018.
//  Copyright © 2018 Poq Studio Ltd. All rights reserved.
//

import Foundation

struct WebCheckoutPayload: Codable {
    /*! @abstract The name of the event from Web Checkout JS */
    let name: String
    
    /*! @abstract data is a JSON string that can be decoded into the expected model based on name. e.g. Order */
    let data: [String : String]
}
