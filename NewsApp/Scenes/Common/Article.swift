//
//  Article.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 13.02.2023.
//

import Foundation

struct Article: Decodable {
    let source: Source?
    let author: String?
    let title, description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    struct Source: Decodable {
        let id, name: String?
    }
    
    static func from(_ articleEntity: ArticleEntity) -> Article {
        Article(
            source: Source(id: nil, name: articleEntity.source),
            author: articleEntity.author,
            title: articleEntity.title,
            description: articleEntity.details,
            url: articleEntity.url,
            urlToImage: articleEntity.urlToImage,
            publishedAt: articleEntity.publishedAt,
            content: articleEntity.content
        )
    }
}
