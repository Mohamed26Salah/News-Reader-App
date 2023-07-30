//
//  APIHandler.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import Foundation

protocol APIProvider {
    func fetchData(for resource: String, completion: @escaping (Result<Data, Error>) -> ())
}

class NetworkAPIProvider: APIProvider {
    func fetchData(for resource: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let apiURL = URL(string: resource) else {
            let customError = NSError(domain: "URL is Wrong", code: 0, userInfo: nil)
            completion(.failure(customError))
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: apiURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let customError = NSError(domain: "NoDataError", code: 0, userInfo: nil)
                completion(.failure(customError))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
}

class APIClient {
    private let baseURL: URL
    private let apiProvider: APIProvider
    
    init(baseURL: URL, apiProvider: APIProvider) {
        self.baseURL = baseURL
        self.apiProvider = apiProvider
    }

    func fetchResourceData<model: Decodable>(modelDTO: model, completion: @escaping (Result<model, Error>) -> Void){
        apiProvider.fetchData(for: baseURL.absoluteString) { result in
            switch result {
            case .success(let data):
                do {
                    let parsedData = try JSONDecoder().decode(model.self, from: data)
                    completion(.success(parsedData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}
