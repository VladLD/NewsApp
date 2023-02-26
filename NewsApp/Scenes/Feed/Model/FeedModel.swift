//
//  FeedModel.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 06.02.2023.
//

import Alamofire

final class FeedModel {
    
    // MARK: - Properties
    
    private let apiKey = "7556b534fff24d59a8826bbf0425c4eb" // "66e158026ce740aba4879bf07e720f99"
    
    private var page = 1
    private var didReachTheEnd = false
    private weak var articlesRequest: DataRequest?
    
    private let dispatchGroup = DispatchGroup()
    
    private(set) var articles: [Article] = []
    private(set) var sources: [Source] = []
    
    // MARK: - Computed properties
    
    var canLoadMoreArticles: Bool {
        articlesRequest == nil && !didReachTheEnd
    }
    
    // MARK: - Internal methods
    
    func loadInitialData(sources: [String], completion: (() -> Void)?) {
        
        dispatchGroup.enter()
        loadArticles(searchQuery: nil, sources: sources, completion: { [weak self] in
            self?.dispatchGroup.leave()
        })
        
        dispatchGroup.enter()
        loadSources(completion: { [weak self] in
            self?.dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: .main, execute: {
            completion?()
        })
    }
    
    func loadArticles(searchQuery: String?, sources: [String], completion: (() -> Void)?) {
        didReachTheEnd = false
        page = 1
        load(searchQuery: searchQuery, sources: sources, completion: completion)
    }
    
    func loadMoreArticles(searchQuery: String?, sources: [String], completion: (() -> Void)?) {
        guard canLoadMoreArticles else {
            return
        }
        page += 1
        load(searchQuery: searchQuery, sources: sources, completion: completion)
    }
    
    // MARK: - Private methods
    
    private func load(searchQuery: String?, sources: [String], completion: (() -> Void)?) {
        let searchQuery = (searchQuery ?? "").isEmpty ? "" : "&q=\(searchQuery!)"
        let sources = sources[0..<min(20, sources.count)].joined(separator: ",")
        
        let url = "https://newsapi.org/v2/everything?sources=\(sources)\(searchQuery)&pageSize=20&page=\(page)&sortBy=publishedAt&apiKey=\(apiKey)"
        
        articlesRequest?.cancel()
        articlesRequest = AF.request(url).response { [weak self] response in
            debugPrint(response)
            defer {
                completion?()
            }
            guard let self, let value = response.value, let data = value else {
                return
            }
            do {
                let articlesResponse = try JSONDecoder().decode(ArticlesResponse.self, from: data)
                let newArticles = articlesResponse.articles ?? []
                if newArticles.isEmpty {
                    self.didReachTheEnd = true
                }
                self.articles = self.page > 1 ? self.articles + newArticles : newArticles
                    
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
    private func loadSources(completion: (() -> Void)?) {
        let url = "https://newsapi.org/v2/top-headlines/sources?apiKey=\(apiKey)"
        
        AF.request(url).response { [weak self] response in
            debugPrint(response)
            defer {
                completion?()
            }
            guard let self, let value = response.value, let data = value else {
                return
            }
            do {
                let sourcesResponse = try JSONDecoder().decode(SourcesResponse.self, from: data)
                let newSources = sourcesResponse.sources ?? []
                self.sources = self.page > 1 ? self.sources + newSources : newSources
                    
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }
    
}
