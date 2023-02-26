//
//  Source.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 14.02.2023.
//

import Foundation

struct Source: Decodable {
    
    static let initial = Source(id: "abc-news", name: nil, description: nil, url: nil, category: nil, language: nil, country: nil)
    
    let id, name, description: String?
    let url: String?
    let category, language, country: String?
}
