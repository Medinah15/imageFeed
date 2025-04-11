//
//  ProfileService.swift
//  imageFeed
//
//  Created by Medina Huseynova on 08.04.25.

import Foundation

// MARK: - ProfileService
final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    private let networkService: NetworkServiceProtocol
    private(set) var profile: Profile?
    
    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            let error = ProfileServiceError.invalidRequest
            logError(method: "fetchProfile", error: error, additionalInfo: "Failed to create request with token: \(token)")
            completion(.failure(error))
            return
        }
        
        networkService.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                self?.logError(method: "fetchProfile", error: error, request: request)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("[makeProfileRequest]: Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: - Logging Errors
    private func logError(method: String, error: Error, request: URLRequest? = nil, additionalInfo: String? = nil) {
        var logMessage = "❌ [\(method)] - Ошибка: \(error.localizedDescription)"
        
        if let additionalInfo = additionalInfo {
            logMessage += ", Info: \(additionalInfo)"
        }
        
        if let request = request {
            logMessage += ", Request: \(request)"
        }
        
        print(logMessage)
    }
}

// MARK: - ProfileResult
struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}

// MARK: - Profile
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

// MARK: - ProfileServiceError
enum ProfileServiceError: Error {
    case invalidRequest
}
