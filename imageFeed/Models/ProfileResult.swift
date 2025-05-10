//
//  ProfileResult.swift
//  imageFeed
//
//  Created by Medina Huseynova on 18.04.25.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
