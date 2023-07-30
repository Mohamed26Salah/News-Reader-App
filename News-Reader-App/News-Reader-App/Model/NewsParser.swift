//
//  NewsParser.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//


import Foundation
import OptionallyDecodable

// MARK: - DecodeScene
struct NewsParser: Codable {
    var status: String
    var totalResults: Int
    var articles: [Article]

    enum CodingKeys: String, CodingKey {
        case status = "status"
        case totalResults = "totalResults"
        case articles = "articles"
    }
}

// MARK: - Article
struct Article: Codable {
    var source: Source
    var author: String
    var title: String
    var description: String
    var url: String
    var urlToImage: String
    var publishedAt: String
    var content: String

    enum CodingKeys: String, CodingKey {
        case source = "source"
        case author = "author"
        case title = "title"
        case description = "description"
        case url = "url"
        case urlToImage = "urlToImage"
        case publishedAt = "publishedAt"
        case content = "content"
    }
}

// MARK: - Source
struct Source: Codable {
    var id: ID?
    var name: Name?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

enum ID: String, Codable {
    case engadget = "engadget"
    case theVerge = "the-verge"
    case wired = "wired"
}

enum Name: String, Codable {
    case engadget = "Engadget"
    case lifehackerCOM = "Lifehacker.com"
    case theVerge = "The Verge"
    case wired = "Wired"
}

