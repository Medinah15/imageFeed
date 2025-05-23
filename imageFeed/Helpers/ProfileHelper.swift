//
//  ProfileHelper.swift
//  imageFeed
//
//  Created by Medina Huseynova on 21.05.25.
//

import Foundation

protocol ProfileHelperProtocol {
    func avatarURL(withBaseURL urlString: String?) -> URL?
}

final class ProfileHelper: ProfileHelperProtocol {
    func avatarURL(withBaseURL urlString: String?) -> URL? {
        guard let urlString = urlString,
              var components = URLComponents(string: urlString) else {
            return nil
        }
        
        components.queryItems = components.queryItems?.filter {
            !["crop", "fit", "w", "h"].contains($0.name)
        }
        
        let newParams: [URLQueryItem] = [
            URLQueryItem(name: "crop", value: "faces"),
            URLQueryItem(name: "w", value: "150"),
            URLQueryItem(name: "h", value: "150")
        ]
        
        if components.queryItems != nil {
            components.queryItems?.append(contentsOf: newParams)
        } else {
            components.queryItems = newParams
        }
        return components.url
    }
    
   
}

