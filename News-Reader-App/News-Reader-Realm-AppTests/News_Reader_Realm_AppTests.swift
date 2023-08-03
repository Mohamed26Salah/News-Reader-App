//
//  News_Reader_Realm_AppTests.swift
//  News-Reader-Realm-AppTests
//
//  Created by Mohamed Salah on 02/08/2023.
//

import XCTest
@testable import News_Reader_App
import RealmSwift

final class News_Reader_Realm_AppTests: XCTestCase {
    var viewModel: NewsViewModel!
    
    override func setUp() {
        super.setUp()
        
        // Use an in-memory Realm for testing
        let configuration = Realm.Configuration(
            objectTypes: [RealmArticle.self, CachedImage.self, RealmSource.self]
        )
        Realm.Configuration.defaultConfiguration = configuration
        
        viewModel = NewsViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Clear the in-memory Realm after each test
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func testCacheArticlesToRealm() {
        let source = Source(id: nil, name: nil)
        let article1 = Article(source: source, author: "Author 1", title: "Title 1", description: "Description 1", url: "https://example.com/1", urlToImage: "https://example.com/image1.jpg", publishedAt: "2023-08-01T12:00:00Z", content: "Content 1")
        let article2 = Article(source: source, author: "Author 2", title: "Title 2", description: "Description 2", url: "https://example.com/2", urlToImage: "https://example.com/image2.jpg", publishedAt: "2023-08-02T12:00:00Z", content: "Content 2")
        
        // Cache the articles
        viewModel.cacheArticlesToRealm(articles: [article1, article2])
        
        // Verify that the articles were cached correctly
        let realm = try! Realm()
        let realmArticles = realm.objects(RealmArticle.self)
        XCTAssertEqual(realmArticles.count, 2)
        
        let realmArticle1 = realmArticles[0]
        XCTAssertEqual(realmArticle1.author, article1.author)
        XCTAssertEqual(realmArticle1.title, article1.title)
        
        let realmArticle2 = realmArticles[1]
        XCTAssertEqual(realmArticle2.author, article2.author)
        XCTAssertEqual(realmArticle2.title, article2.title)
    }
    
    func testGetCachedArticlesFromRealm() {
        let source = Source(id: nil, name: nil)
        let article1 = Article(source: source, author: "Author 1", title: "Title 1", description: "Description 1", url: "https://example.com/1", urlToImage: "https://example.com/image1.jpg", publishedAt: "2023-08-01T12:00:00Z", content: "Content 1")
        let article2 = Article(source: source, author: "Author 2", title: "Title 2", description: "Description 2", url: "https://example.com/2", urlToImage: "https://example.com/image2.jpg", publishedAt: "2023-08-02T1200:00Z", content: "Content 2")
        
        // Cache the articles
        viewModel.cacheArticlesToRealm(articles: [article1, article2])
        
        // Retrieve the cached articles
        let cachedArticles = viewModel.getCachedArticlesFromRealm()
        
        // Verify that the cached articles were retrieved correctly
        XCTAssertEqual(cachedArticles.count, 2)
        
        let cachedArticle1 = cachedArticles[0]
        XCTAssertEqual(cachedArticle1.author, article1.author)
        XCTAssertEqual(cachedArticle1.title, article1.title)
        
        let cachedArticle2 = cachedArticles[1]
        XCTAssertEqual(cachedArticle2.author, article2.author)
        XCTAssertEqual(cachedArticle2.title, article2.title)
    }
    
}
