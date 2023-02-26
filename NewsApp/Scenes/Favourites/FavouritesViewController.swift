//
//  FavouritesViewController.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 20.02.2023.
//

import UIKit
import RealmSwift

final class FavouritesViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let realmManager: RealmManager = .shared
    private var articlesObserver: NotificationToken!
    
    // MARK: - Lifecycle
    
    deinit {
        articlesObserver?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Internal methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let webViewController as WebViewController:
            guard let cell = sender as? ArticleTableViewCell,
                  let indexPath = tableView.indexPath(for: cell)
            else {
                return
            }
            webViewController.apply(article: Article.from(realmManager.articles[indexPath.row]))
            
        default:
            assertionFailure()
        }
        
    }
    
    // MARK: - Private methods
    
    private func configure() {
        configureTableView()
        configureArticlesObserver()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(
            UINib(nibName: ArticleTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: ArticleTableViewCell.identifier
        )
    }
    
    private func configureArticlesObserver() {
        articlesObserver = realmManager.articles.observe { [unowned self] (changes) in
            switch changes {
            case .initial, .update:
                tableView.reloadData()
            case .error(let error):
                assertionFailure(error.localizedDescription)
            }
        }
    }

}

// MARK: - UITableViewDataSource

extension FavouritesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        realmManager.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifier, for: indexPath
        ) as! ArticleTableViewCell
        
        let article = Article.from(realmManager.articles[indexPath.row])
        cell.apply(item: article)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension FavouritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(
            withIdentifier: String(describing: WebViewController.self),
            sender: tableView.cellForRow(at: indexPath)
        )
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let persistedArticle = realmManager.articles[indexPath.row]
        
        let removeAction = UIContextualAction(
            style: .destructive,
            title: "Remove from favourites",
            handler: { [unowned self] _,_, completion in
                realmManager.delete(article: persistedArticle, withoutNotifying: [articlesObserver])
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            }
        )
        removeAction.image = UIImage(systemName: "xmark.bin.fill")
        
        let config = UISwipeActionsConfiguration(actions: [removeAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
}

