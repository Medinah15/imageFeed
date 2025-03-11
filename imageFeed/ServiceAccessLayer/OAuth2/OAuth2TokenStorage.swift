//
//  OAuth2TokenStorage.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.03.25.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
}

