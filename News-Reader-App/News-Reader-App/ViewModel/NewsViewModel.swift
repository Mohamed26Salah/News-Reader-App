//
//  NewsViewModel.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import Foundation

class NewsViewModel: ObservableObject {
    private let provider = NetworkAPIProvider()
    private let baseURL = URL(string: "https://newsapi.org/v2/everything?q=Apple&from=2023-06-30&sortBy=popularity&apiKey=3f913531a6404bc4a4b63f57f4c7dff8")
    private let apiHandler: APIClient
    @Published var newsData: NewsParser?
    @Published var newsAbout: String = "Apple"
    init() {
        guard let apiURL = baseURL else {
            fatalError("Failed to create baseURL")
        }
        apiHandler = APIClient(baseURL: apiURL, apiProvider: provider)
        apiHandler.fetchResourceData(modelDTO: newsData, completion: { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.newsData = data
                }
            case .failure(let error):
                print(error)
            }
        })
    }
 
}
