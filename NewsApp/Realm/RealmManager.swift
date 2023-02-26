//
//  RealmManager.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 24.02.2023.
//

import RealmSwift

final class RealmManager {
    
    static let shared = RealmManager()
    
    private init() {}
    
    private let _realm: Realm = {
        // first init check
        do {
            return try Realm()
        } catch {
            fatalError(error.localizedDescription)
        }
    }()
    
    var realm: Realm {
        if Thread.isMainThread {
            return _realm
        } else {
            // ensure thread safety
            return try! Realm()
        }
    }
    
    lazy var articles = realm.objects(ArticleEntity.self).sorted(byKeyPath: "creationDate", ascending: false)
    
    func articleEntity(forArticle article: Article) -> ArticleEntity? {
        guard let url = article.url, !url.isEmpty,
              let articleEntity = articles.first(where: { $0.url == url })
        else {
            return nil
        }
        return articleEntity
    }
    
    func add(article: Article, withoutNotifying tokens: [NotificationToken] = []) {
        let articleEntity = ArticleEntity()
        
        articleEntity.source = article.source?.name ?? ""
        articleEntity.author = article.author ?? ""
        articleEntity.title = article.title ?? ""
        articleEntity.details = article.description ?? ""
        articleEntity.url = article.url ?? ""
        articleEntity.urlToImage = article.urlToImage ?? ""
        articleEntity.publishedAt = article.publishedAt ?? ""
        articleEntity.content = article.content ?? ""
        
        add(article: articleEntity, withoutNotifying: tokens)
    }
    
    func add(article: ArticleEntity, withoutNotifying tokens: [NotificationToken] = []) {
        autoreleasepool {
            try! realm.write {
                realm.add(article)
            }
        }
    }
    
    func delete(article: Article, withoutNotifying tokens: [NotificationToken] = []) {
        guard let articleEntity = articleEntity(forArticle: article) else {
            return
        }
        delete(article: articleEntity, withoutNotifying: tokens)
    }
    
    func delete(article: ArticleEntity, withoutNotifying tokens: [NotificationToken] = []) {
        autoreleasepool {
            try! realm.write {
                realm.delete(article)
            }
        }
    }
    
}

