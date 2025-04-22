//
//  ImagesListService.swift
//  imageFeed
//
//  Created by Medina Huseynova on 21.04.25.
//

import UIKit

final class ImagesListService {
    
    // MARK: - Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var isFetching = false
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private init() {}
    
    // MARK: - Methods
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else {
            isFetching = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.isFetching = false }
            guard let self = self, let data = data, error == nil else { return }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: self.dateFormatter.date(from: result.created_at ?? ""),
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.liked_by_user
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("Ошибка декодирования: \(error)")
            }
        }
        task.resume()
    }
}

