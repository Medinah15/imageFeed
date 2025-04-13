//
//  OAuth2TokenStorage.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.03.25.

import Foundation
import SwiftKeychainWrapper


import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
                if !isSuccess {
                    print("❌ [OAuth2TokenStorage]: Не удалось сохранить токен в Keychain")
                }
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !isSuccess {
                    print("⚠️ [OAuth2TokenStorage]: Не удалось удалить токен из Keychain")
                }
            }
        }
    }
}
