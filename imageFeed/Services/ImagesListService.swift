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
    private var lastLoadedPage: Int?
    private var isLoading = false
    
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1

        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10&client_id=\(Constants.accessKey)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            print("[fetchPhotosNextPage, ImagesListService]: [Invalid URL] urlString: \(urlString)")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                   defer { self?.isLoading = false }
                   guard let self = self else { return }
                   
                   if let error = error {
                       print("[fetchPhotosNextPage, ImagesListService]: [Network Error] error: \(error.localizedDescription)")
                       return
                   }
                   
                   guard let data = data else {
                       print("[fetchPhotosNextPage, ImagesListService]: [No Data] response: \(String(describing: response))")
                       return
                   }
            
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
                        fullImageURL: result.urls.full,
                        isLiked: result.liked_by_user
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            } catch {
                print("[fetchPhotosNextPage, ImagesListService]: [Decoding Error] data: \(String(data: data, encoding: .utf8) ?? "N/A") error: \(error)")
            }
        }
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[changeLike, ImagesListService]: [Invalid URL] photoId: \(photoId)")
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[changeLike, ImagesListService]: [No Token] photoId: \(photoId)")
            completion(.failure(NetworkError.invalidToken))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[changeLike, ImagesListService]: [Network Error] photoId: \(photoId), error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusError = NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? 500)
                print("[changeLike, ImagesListService]: [HTTP Error] photoId: \(photoId), statusCode: \((response as? HTTPURLResponse)?.statusCode ?? 0), error: \(statusError)")
                completion(.failure(statusError))
                return
            }
            
            DispatchQueue.main.async {
                // Обновляем модель
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
                completion(.success(()))
            }
        }
        
        task.resume()
    }
    
    func reset() {
        photos = []
        lastLoadedPage = nil
    }
}
