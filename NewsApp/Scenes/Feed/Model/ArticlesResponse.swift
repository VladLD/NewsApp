//
//  ArticlesResponse.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 12.02.2023.
//

import Foundation

struct ArticlesResponse: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}
