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
    private var task: URLSessionTask?
    private var lastCode: String?
    private let networkService: NetworkServiceProtocol
    
    private init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            let error = AuthServiceError.invalidRequest
            logError(method: "fetchOAuthToken", error: error, additionalInfo: "Code: \(code)")
            completion(.failure(error))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = AuthServiceError.invalidRequest
            logError(method: "fetchOAuthToken", error: error, additionalInfo: "Failed to create request, Code: \(code)")
            completion(.failure(error))
            return
        }
        
        task = networkService.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            self?.task = nil
            self?.lastCode = nil
            
            switch result {
            case .success(let response):
                let token = response.accessToken
                self?.storage.token = token
                print("✅ [fetchOAuthToken]: Токен успешно получен и сохранён: \(token)")
                completion(.success(token))
            case .failure(let error):
                self?.logError(method: "fetchOAuthToken", error: error, request: request)
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token"
                            + "?client_id=\(Constants.accessKey)"
                            + "&client_secret=\(Constants.secretKey)"
                            + "&redirect_uri=\(Constants.redirectURI)"
                            + "&code=\(code)"
                            + "&grant_type=authorization_code") else {
            assertionFailure("[makeOAuthTokenRequest]: Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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

