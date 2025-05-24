//
//  Photo .swift
//  imageFeed
//
//  Created by Medina Huseynova on 22.04.25.
//

import Foundation

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}
