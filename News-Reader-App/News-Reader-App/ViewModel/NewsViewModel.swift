//
//  NewsViewModel.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import Foundation
import RealmSwift

class NewsViewModel: ObservableObject {
    private let provider = NetworkAPIProvider()
    private let baseURL = URL(string: "https://newsapi.org/v2/everything?q=Apple&from=2023-06-30&sortBy=popularity&apiKey=3f913531a6404bc4a4b63f57f4c7dff8")
    private let apiHandler: APIClient
    @Published var newsData: NewsParser?
    @Published var newsAbout: String = "Apple"
    @Published var showError: Bool = false
    @Published var isTheirAnError: Bool = false
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
                print("Working")
                getDataFromParser(data: data)
            case .failure(let error):
                getDataFromRealm()
            }
        })
        
    }
    private func getDataFromParser(data: NewsParser?) {
        DispatchQueue.main.async {
            print(self.newsData?.articles.count)
            self.newsData?.articles.removeAll()
            print(self.newsData?.articles.count)
            self.newsData = data
            print(self.newsData?.articles.count)
            //                    self.isTheirAnError = false
        }
        if let dataToCache = data {
            self.clearCachedData()
            self.cacheArticlesToRealm(articles: dataToCache.articles)
        }
    }
    private func getDataFromRealm() {
        DispatchQueue.main.async {
            self.isTheirAnError = true
            self.showError.toggle()
            let cachedArticles = self.getCachedArticlesFromRealm()
            let newsParser = NewsParser(status: "200", totalResults: cachedArticles.count, articles: cachedArticles)
            self.newsData = newsParser
        }
    }
    
    func cacheArticlesToRealm(articles: [Article]) {
        do {
            let realm = try Realm()
            print(realm.configuration.fileURL!)
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
            for article in articles {
                if let imageURL = URL(string: article.urlToImage), let imageData = try? Data(contentsOf: imageURL) {
                    let cachedImage = CachedImage()
                    cachedImage.url = article.url
                    cachedImage.imageData = imageData
                    try realm.write {
                        realm.add(cachedImage, update: .modified)
                    }
                }
            }
        } catch {
            print("Error caching articles to Realm: \(error)")
        }
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
            print("Error retrieving cached articles from Realm: \(error)")
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
            print("Error retrieving cached image from Realm: \(error)")
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
            print("Error clearing cached data: \(error)")
        }
    }
    
    
}
