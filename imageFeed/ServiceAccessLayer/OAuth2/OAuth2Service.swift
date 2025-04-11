//
//  OAuth2Service.swift
//  imageFeed
//
//  Created by Medina Huseynova on 04.03.25.

import Foundation

// MARK: - AuthServiceError Enum
enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            self?.task = nil
            self?.lastCode = nil
            
            switch result {
            case .success(let response):
                let token = response.accessToken
                self?.storage.token = token
                print("✅ Токен успешно получен и сохранён: \(token)")
                completion(.success(token))
            case .failure(let error):
                print("❌ Ошибка при получении токена: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token"
                            + "?client_id=\(Constants.accessKey)"
                            + "&client_secret=\(Constants.secretKey)"
                            + "&redirect_uri=\(Constants.redirectURI)"
                            + "&code=\(code)"
                            + "&grant_type=authorization_code") else {
            assertionFailure("Не удалось создать URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

// MARK: - OAuthTokenResponse
struct OAuthTokenResponse: Codable {
    let accessToken: String
}
