//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 06.02.2023.
//

import UIKit
import AlamofireImage

final class ArticleTableViewCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    @IBOutlet private weak var articleImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    // MARK: - Internal methods
    
    func apply(item: Article) {
        
        loadingView.stopAnimating()
        articleImageView.image = nil
        
        if let imagePath = item.urlToImage, let imageURL = URL(string: imagePath) {
            loadingView.startAnimating()
            articleImageView.af.setImage(withURL: imageURL, completion: { [weak self] _ in
                self?.loadingView.stopAnimating()
            })
        }
        
        titleLabel.text = item.title
        
        sourceLabel.text = item.source?.name
        sourceLabel.isHidden = item.source?.name == nil || item.source!.name!.isEmpty
        
        authorLabel.text = item.author
        authorLabel.isHidden = item.author == nil || item.author!.isEmpty
    }
    
    // MARK: - Private methods
    
    private func configure() {
        
    }
    
}
