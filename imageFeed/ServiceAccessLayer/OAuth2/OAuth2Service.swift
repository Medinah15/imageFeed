//
//  OAuth2Service.swift
//  imageFeed
//
//  Created by Medina Huseynova on 04.03.25.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    private init() {}
    
    // MARK: - Public Methods
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания запроса"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
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
                    // Используем кастомный декодер с настроенным convertFromSnakeCase
                    let decoder = SnakeCaseJSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let token = response.accessToken
                    self.storage.token = token
                    print("✅ Токен успешно получен и сохранён: \(token)")
                    completion(.success(token))
                } catch {
                    print("❌ Ошибка декодирования JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("❌ Ошибка: не удалось создать baseURL")
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(WebViewConstants.accessKey)"
            + "&client_secret=\(WebViewConstants.secretKey)"
            + "&redirect_uri=\(WebViewConstants.redirectURI)"
            + "&code=\(code)"
            + "&grant_type=authorization_code",
            relativeTo: WebViewConstants.baseURL
        ) else {
            print("❌ Ошибка: не удалось создать URL для OAuth запроса")
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
