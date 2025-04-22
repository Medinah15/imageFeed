//
//  PhotoResult.swift
//  imageFeed
//
//  Created by Medina Huseynova on 22.04.25.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let created_at: String?
    let description: String?
    let liked_by_user: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

