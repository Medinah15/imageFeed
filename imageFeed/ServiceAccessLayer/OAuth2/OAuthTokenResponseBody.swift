//
//  OAuthTokenResponseBody.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.03.25.
//
import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
}

class SnakeCaseJSONDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}


