//
//  ArticleEntity.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 25.02.2023.
//

import Foundation
import RealmSwift

final class ArticleEntity: Object {
    @Persisted var source: String = ""
    @Persisted var author: String = ""
    @Persisted var title: String = ""
    @Persisted var details: String = ""
    @Persisted var url: String = ""
    @Persisted var urlToImage: String = ""
    @Persisted var publishedAt: String = ""
    @Persisted var content: String = ""
    
    @Persisted var creationDate: Date = Date()
    
    override class func primaryKey() -> String? {
        return "url"
    }
    
}
