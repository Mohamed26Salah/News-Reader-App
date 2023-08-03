//
//  NewsViewModel.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import Foundation
import RealmSwift
import UIKit

class NewsViewModel: ObservableObject {
    private let provider = NetworkAPIProvider()
    private let baseURL = URL(string: "https://newsapi.org/v2/everything?q=Google&from=2023-07-02&sortBy=popularity&apiKey=3f913531a6404bc4a4b63f57f4c7dff8")
    private let apiHandler: APIClient
    @Published var queury: String = "Apple"
    @Published var newsData: NewsParser?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isTheirAnError: Bool = false
    @Published var isRefreshDisabled: Bool = false
    init() {
        guard let apiURL = baseURL else {
            fatalError("Failed to create baseURL")
        }
        apiHandler = APIClient(baseURL: apiURL, apiProvider: provider)
        fetchDataFromApi()
    }
    
    func fetchDataFromApi() {
        apiHandler.fetchResourceData(modelDTO: newsData, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                print("Success")
                getDataFromParser(data: data)
            case .failure(let error):
                getDataFromRealm(error)
            }
        })
        
    }
    func searchAPI() {
        apiHandler.baseURL = URL(string: "https://newsapi.org/v2/everything?q=\(queury)&from=2023-07-02&sortBy=popularity&apiKey=3f913531a6404bc4a4b63f57f4c7dff8")!
        fetchDataFromApi()
    }
    private func getDataFromParser(data: NewsParser?) {
        DispatchQueue.main.async {
            self.newsData = data
            //To Give the feeling of an Refresh
            self.newsData?.articles.shuffle()
            self.isTheirAnError = false
        }
        if let dataToCache = data {
            self.clearCachedData()
            self.cacheArticlesToRealm(articles: dataToCache.articles)
        }
    }
    private func getDataFromRealm(_ error: Error) {
        let cachedArticles = self.getCachedArticlesFromRealm()
        let newsParser = NewsParser(status: "200", totalResults: cachedArticles.count, articles: cachedArticles)
        DispatchQueue.main.async {
            self.isTheirAnError = true
            self.showError.toggle()
            self.errorMessage = error.localizedDescription
            self.newsData = newsParser
        }
    }
    
    func cacheArticlesToRealm(articles: [Article]) {
        do {
            let realm = try Realm()
            // Convert Article objects to RealmArticle and save them
            try realm.write {
                for article in articles {
                    let realmSource = RealmSource(source: article.source)
                    let realmArticle = RealmArticle()
                    realmArticle.url = article.url
                    realmArticle.source = realmSource
                    realmArticle.author = article.author
                    realmArticle.title = article.title
                    realmArticle.articleDescription = article.description
                    realmArticle.urlToImage = article.urlToImage
                    realmArticle.publishedAt = article.publishedAt
                    realmArticle.content = article.content
                    realm.add(realmArticle, update: .modified)
                }
            }
            
            // Cache the images as CachedImage objects
            DispatchQueue.main.async {
                self.isRefreshDisabled = true
            }
            cachImagesAsync(articles: articles) {
                DispatchQueue.main.async {
                    self.isRefreshDisabled = false
                }
                
            }
        } catch {
            DispatchQueue.main.async {
                self.showError.toggle()
                self.errorMessage = "Error in saving the news"
            }
        }
    }
    func cachImagesAsync(articles: [Article], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()

        for article in articles {
            if let imageURL = URL(string: article.urlToImage) {
                dispatchGroup.enter()
                let task = URLSession.shared.dataTask(with: imageURL) { data, _, error in
                    if let imageData = data {
                        if let compressedImageData = UIImage(data: imageData)?.jpeg(.lowest) {
                            DispatchQueue.main.async {
                                do {
                                    let realm = try Realm()
                                    let cachedImage = CachedImage()
                                    cachedImage.url = article.url
                                    cachedImage.imageData = compressedImageData
                                    
                                    try realm.write {
                                        realm.add(cachedImage, update: .modified)
                                    }
                                } catch {
                                    print("Error updating Realm with compressed image data: \(error)")
                                }
                                
                                dispatchGroup.leave()
                            }
                        } else {
                            print("Error compressing the image.")
                            dispatchGroup.leave()
                        }
                    } else if let error = error {
                        print("Error downloading the image: \(error)")
                        dispatchGroup.leave()
                    }
                }
                task.resume()
            }
        }
        
        dispatchGroup.leave()

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }


    func cachImagesSync(articles: [Article]) {
//        for article in articles {
//            if let imageURL = URL(string: article.urlToImage),
//               let image = UIImage(data: try Data(contentsOf: imageURL)),
//               let imageData = image.jpeg(.lowest) {
//                let cachedImage = CachedImage()
//                cachedImage.url = article.url
//                cachedImage.imageData = imageData
//                try realm.write {
//                    realm.add(cachedImage, update: .modified)
//                }
//            }
//        }
    }
    // Step 4: Retrieve cached articles and images
    
    func getCachedArticlesFromRealm() -> [Article] {
        do {
            let realm = try Realm()
            let realmArticles = realm.objects(RealmArticle.self)
            
            // Convert RealmArticle objects to Article objects
            return realmArticles.map { realmArticle in
                let sourceId = SourceIdentifier.shared.getSourceID(sourceId: realmArticle.source?.id)
                let sourceName = SourceIdentifier.shared.getSourceName(sourceName: realmArticle.source?.name)
                let source = Source(id: sourceId, name: sourceName)
                return Article(
                    source: source,
                    author: realmArticle.author,
                    title: realmArticle.title,
                    description: realmArticle.articleDescription,
                    url: realmArticle.url,
                    urlToImage: realmArticle.urlToImage,
                    publishedAt: realmArticle.publishedAt,
                    content: realmArticle.content
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.showError.toggle()
                self.errorMessage = "Error retrieving saved articles"
            }
            return []
        }
    }
    
    func getCachedImageFromRealm(url: String) -> Data? {
        do {
            let realm = try Realm()
            if let cachedImage = realm.object(ofType: CachedImage.self, forPrimaryKey: url) {
                return cachedImage.imageData
            }
        } catch {
            DispatchQueue.main.async {
                self.showError.toggle()
                self.errorMessage = "Error retrieving cached image"
            }
        }
        return nil
    }
    private func clearCachedData() {
        do {
            let realm = try Realm()
            
            try realm.write {
                // Delete all objects of RealmArticle and CachedImage classes
                realm.delete(realm.objects(RealmArticle.self))
                realm.delete(realm.objects(CachedImage.self))
                realm.delete(realm.objects(RealmSource.self))
            }
        } catch {
            DispatchQueue.main.async {
                self.showError.toggle()
                self.errorMessage = "SomeThing Went Wrong"
            }
        }
    }
    
    
}
