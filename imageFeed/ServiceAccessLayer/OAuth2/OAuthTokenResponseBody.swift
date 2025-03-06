//
//  OAuthTokenResponseBody.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.03.25.
//
import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

