//
//  RealmArticle.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 31/07/2023.
//

import Foundation
import RealmSwift
class RealmArticle: Object {
    @Persisted(primaryKey: true) var url: String
    @Persisted var author: String
    @Persisted var title: String
    @Persisted var articleDescription: String
    @Persisted var urlToImage: String
    @Persisted var publishedAt: String
    @Persisted var content: String
    @Persisted var source: RealmSource?
}

class RealmSource: Object {
    @objc dynamic var id: String?
    @objc dynamic var name: String?

    convenience init(source: Source) {
        self.init()
        self.id = source.id?.rawValue
        self.name = source.name?.rawValue
    }
}
// Realm CachedImage object class
class CachedImage: Object {
    @Persisted(primaryKey: true) var url: String
    @Persisted var imageData: Data
}
class SourceIdentifier {
    static let shared = SourceIdentifier()

    private init() {
    }

    func getSourceID(sourceId: String?) -> ID? {
        if let id = sourceId {
            switch id {
            case "engadget":
                return .engadget
            case "the-verge":
                return .theVerge
            case "wired":
                return .wired
            default:
                return nil
            }
        } else {
            return nil
        }
    }

    func getSourceName(sourceName: String?) -> Name? {
        if let name = sourceName {
            switch name {
            case "Engadget":
                return .engadget
            case "Lifehacker.com":
                return .lifehackerCOM
            case "The Verge":
                return .theVerge
            case "Wired":
                return .wired
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

