//
//  Profile.swift
//  imageFeed
//
//  Created by Medina Huseynova on 18.04.25.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.name = "\(result.firstName ?? "") \(result.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}
