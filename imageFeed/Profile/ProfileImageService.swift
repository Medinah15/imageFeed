//
//  ProfileImageService.swift
//  imageFeed
//
//  Created by Medina Huseynova on 09.04.25.

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
    }
}

final class ProfileImageService {

    // MARK: - Singleton
    static let shared = ProfileImageService()
    private let urlSession = URLSession.shared
    private var currentTask: URLSessionTask?
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(ProfileImageServiceError.unauthorized))
            return
        }
        
        let request = makeRequest(for: username, token: token)
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ProfileImageServiceError.invalidResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let smallImageURL = userResult.profileImage.small
                    self?.avatarURL = smallImageURL
                    completion(.success(smallImageURL))
                    
                    NotificationCenter.default.post(
                                            name: ProfileImageService.didChangeNotification,
                                            object: self,
                                            userInfo: ["URL": smallImageURL]
                                        )
                    
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeRequest(for username: String, token: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            fatalError("Не удалось создать URL для запроса пользователя")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

enum ProfileImageServiceError: Error {
    case unauthorized
    case invalidResponse
}

