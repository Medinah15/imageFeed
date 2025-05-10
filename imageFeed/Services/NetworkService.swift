//
//  NetworkService.swift
//  imageFeed
//
//  Created by Medina Huseynova on 11.04.25.
//

import Foundation

// MARK: - NetworkError
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
    case invalidToken
}

// MARK: - NetworkServiceProtocol
protocol NetworkServiceProtocol {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask
}

// MARK: - NetworkService
final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[objectTask]: NetworkError - urlRequestError: \(error.localizedDescription), Request: \(request)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[objectTask]: NetworkError - urlSessionError: No HTTP response, Request: \(request)")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let statusCodeError = NetworkError.httpStatusCode(httpResponse.statusCode)
                    print("[objectTask]: \(statusCodeError) - StatusCode: \(httpResponse.statusCode), Request: \(request)")
                    completion(.failure(statusCodeError))
                    return
                }
                
                guard let data = data else {
                    print("[objectTask]: NetworkError - urlSessionError: No data, Request: \(request)")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                do {
                    let object = try self.decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    print("[objectTask]: NetworkError - decodingError: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? ""), Request: \(request)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            }
        }
        
        task.resume()
        return task
    }
}
