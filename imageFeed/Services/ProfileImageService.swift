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

enum ProfileImageServiceError: Error {
    case unauthorized
    case invalidResponse
}

final class ProfileImageService {
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private var currentTask: URLSessionTask?
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let networkService: NetworkServiceProtocol
    
    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = ProfileImageServiceError.unauthorized
            logError(method: "fetchProfileImageURL", error: error, additionalInfo: "Token is missing")
            completion(.failure(error))
            return
        }
        
        let request = makeRequest(for: username, token: token)
        
        currentTask = networkService.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let imageURL = userResult.profileImage.small
                self?.avatarURL = imageURL
                print("✅ [fetchProfileImageURL]: Успешно получен URL аватара: \(imageURL)")
                completion(.success(imageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": imageURL]
                )
            case .failure(let error):
                self?.logError(method: "fetchProfileImageURL", error: error, request: request)
                completion(.failure(error))
            }
        }
    }
    
    func reset() {
        self.avatarURL = nil
    }

    
    // MARK: - Private Methods
    private func makeRequest(for username: String, token: String) -> URLRequest {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            fatalError("❌ [makeRequest]: Не удалось создать URL для пользователя: \(username)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    // MARK: - Logging
    private func logError(method: String, error: Error, request: URLRequest? = nil, additionalInfo: String? = nil) {
        var log = "❌ [\(method)] - Ошибка: \(error.localizedDescription)"
        
        if let additionalInfo = additionalInfo {
            log += ", Info: \(additionalInfo)"
        }
        
        if let request = request {
            log += ", Request: \(request)"
        }
        
        print(log)
    }
}
