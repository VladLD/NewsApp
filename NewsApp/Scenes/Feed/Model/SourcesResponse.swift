//
//  SourcesResponse.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 16.02.2023.
//

import Foundation

struct SourcesResponse: Decodable {
    let status: String?
    let sources: [Source]?
}
