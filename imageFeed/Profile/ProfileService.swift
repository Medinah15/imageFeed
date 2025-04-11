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
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("❌ Ошибка при получении профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
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

