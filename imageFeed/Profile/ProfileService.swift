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
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка сети: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Ошибка: некорректный ответ от сервера")
                    completion(.failure(NSError(domain: "ProfileService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ от сервера"])))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Ошибка: сервер вернул код ответа \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "ProfileService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])))
                    return
                }
                
                guard let data = data else {
                    print("❌ Ошибка: пустой ответ от сервера")
                    completion(.failure(NSError(domain: "ProfileService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Пустой ответ от сервера"])))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResult)
                    completion(.success(profile))
                } catch {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
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

