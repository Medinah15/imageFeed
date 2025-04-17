//
//  URLSession+data.swift
//  imageFeed
//
//  Created by Medina Huseynova on 04.03.25.

import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    print("[data(for:)]: \(error) - StatusCode: \(statusCode), Request: \(request)")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            } else if let error = error {
                let networkError = NetworkError.urlRequestError(error)
                print("[data(for:)]: \(networkError) - Error: \(error.localizedDescription), Request: \(request)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            } else {
                let networkError = NetworkError.urlSessionError
                print("[data(for:)]: \(networkError) - No data or response, Request: \(request)")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            }
        })
        
        task.resume()
        return task
    }
}
