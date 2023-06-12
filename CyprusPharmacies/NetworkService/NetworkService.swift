//
//  NetworkService.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 10.04.2022.
//

import Foundation

enum NetworkServiceError: Error {
    case isNetworkError(Int)
    case isBackendError(Int)
    case isParserError
    case rawError(Error)
}

class BaseNetworkService<Output: Decodable> {
    func dataTask(with url: URL, completionHandler: @escaping (Result<Output, NetworkServiceError>) -> Void) -> URLSessionDataTask {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                let serviceError = NetworkServiceError.rawError(error)
                completionHandler(Result.failure(serviceError))
                return
            }
            guard let response = response as? HTTPURLResponse else {return}
            let status = response.statusCode
            guard (200...299).contains(status) else {
                var error = NetworkServiceError.isNetworkError(status)
                if (400...499).contains(status) {
                    error = NetworkServiceError.isNetworkError(status)
                }
                if (500...599).contains(status) {
                    error = NetworkServiceError.isBackendError(status)
                }
                completionHandler(Result.failure(error))
                return
            }
            if let safeData = data {
                do {
                    let decodedData = try JSONDecoder().decode(Output.self, from: safeData)
                    completionHandler(Result.success(decodedData))
                } catch {
                    let parserError = NetworkServiceError.isParserError
                    completionHandler(Result.failure(parserError))
                }
            }
        }
        return dataTask
    }
}
