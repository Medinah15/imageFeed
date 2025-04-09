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
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
                
                if let error = error {
                    print("❌ Ошибка сети: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Ошибка: некорректный ответ от сервера")
                    completion(.failure(NSError(domain: "OAuth2Service", code: -2, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ от сервера"])))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Ошибка: сервер вернул код ответа \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "OAuth2Service", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка сервера"])))
                    return
                }
                
                guard let data = data else {
                    print("❌ Ошибка: пустой ответ от сервера")
                    completion(.failure(NSError(domain: "OAuth2Service", code: -3, userInfo: [NSLocalizedDescriptionKey: "Пустой ответ от сервера"])))
                    return
                }
                
                do {
                    let decoder = SnakeCaseJSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    self?.storage.token = token
                    print("✅ Токен успешно получен и сохранён: \(token)")
                    completion(.success(token))
                } catch {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
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
