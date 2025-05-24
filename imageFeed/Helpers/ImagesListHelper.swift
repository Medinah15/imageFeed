//
//  ImagesListHelper.swift
//  imageFeed
//
//  Created by Medina Huseynova on 21.05.25.
//

import Foundation

protocol ImagesListHelperProtocol {
    func formattedDate(from date: Date?) -> String
}

final class ImagesListHelper: ImagesListHelperProtocol {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }
}
