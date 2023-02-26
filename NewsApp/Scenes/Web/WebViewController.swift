//
//  WebViewController.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 11.02.2023.
//

import UIKit
import WebKit

final class WebViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var webView: WKWebView!
    
    // MARK: - Properties
    
    private var article: Article!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    // MARK: - Internal methods
    
    func apply(article: Article) {
        self.article = article
    }
    
    // MARK: - Private methods
    
    private func load() {
        guard let url = article.url, let url = URL(string: url) else {
            return
        }
        webView.load(URLRequest(url: url))
    }

}
