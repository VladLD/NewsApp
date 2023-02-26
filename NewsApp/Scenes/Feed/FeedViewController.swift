//
//  FeedViewController.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 04.02.2023.
//

import UIKit

final class FeedViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let model = FeedModel()
    private let realmManager: RealmManager = .shared
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchQuery = ""
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        view.hidesWhenStopped = true
        return view
    }()
    
    private var filteredSources: [Source] = [.initial]
    
    // MARK: - Computed properties
    
    private var sourceIDs: [String] {
        filteredSources.compactMap(\.id)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        getData(isInitial: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let webViewController as WebViewController:
            guard let cell = sender as? ArticleTableViewCell,
                  let indexPath = tableView.indexPath(for: cell)
            else {
                return
            }
            webViewController.apply(article: model.articles[indexPath.row])
            
        case let filtersViewController as FiltersViewController:
            filtersViewController.set(sources: model.sources)
            filtersViewController.set(selectedSources: filteredSources)
            filtersViewController.set(completion: { [unowned self] sources in
                filteredSources = sources
                getData()
            })
            
            guard let sheet = filtersViewController.sheetPresentationController else {
                return assertionFailure()
            }
            sheet.detents = [.large(), .medium()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            
        default:
            assertionFailure()
        }

    }
    
    // MARK: - Private methods
    
    private func configure() {
        configureSearchController()
        configureTableView()
    }
    
    private func configureSearchController() {
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false

        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .black
        searchController.searchBar.enablesReturnKeyAutomatically = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func configureTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(
            UINib(nibName: ArticleTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: ArticleTableViewCell.identifier
        )
        tableView.keyboardDismissMode = .interactive
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func applySearchIfNeeded() {
        let newSearchQuery = searchController.searchBar.text ?? ""

        guard searchQuery != newSearchQuery else {
            return
        }
        searchQuery = newSearchQuery
        
        getData()
    }
    
    private func getData(isInitial: Bool = false) {
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            loadingView.startAnimating()
        }
        if isInitial {
            model.loadInitialData(sources: sourceIDs, completion: { [weak self] in
                self?.refresh()
            })
        } else {
            model.loadArticles(searchQuery: searchQuery, sources: sourceIDs, completion: { [weak self] in
                self?.refresh()
            })
        }
    }
    
    private func getMoreDataIfPossible() {
        guard model.canLoadMoreArticles else {
            return
        }
        loadingView.startAnimating()
        model.loadMoreArticles(searchQuery: searchQuery, sources: sourceIDs, completion: { [weak self] in
            self?.refresh()
        })
    }
    
    private func refresh() {
        searchController.searchBar.text = searchQuery
        
        loadingView.stopAnimating()
        
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    // MARK: - Selectors
    
    @objc private func didPullToRefresh(_ sender: UIRefreshControl) {
        getData()
    }

}

// MARK: - UISearchResultsUpdating

extension FeedViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {}

}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        applySearchIfNeeded()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        let text = searchBar.text == searchQuery ? "" : searchQuery
        
        /*
         Cancel button clears text after this method is called.
         So we should set new text after that using `DispatchQueue.main.async`
         */
        
        DispatchQueue.main.async {
            searchBar.text = text
            self.applySearchIfNeeded()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifier, for: indexPath
        ) as! ArticleTableViewCell
        
        cell.apply(item: model.articles[indexPath.row])
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        loadingView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        guard numberOfRows > 0, indexPath.row + 1 == numberOfRows else {
            return
        }
        getMoreDataIfPossible()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(
            withIdentifier: String(describing: WebViewController.self),
            sender: tableView.cellForRow(at: indexPath)
        )
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let article = model.articles[indexPath.row]
        
        return UIContextMenuConfiguration(actionProvider: { [unowned self] _ in
            
            let persistedArticle = realmManager.articleEntity(forArticle: article)
            let title = persistedArticle == nil ? "Add to favourites" : "Remove from favourites"
            
            let favAction = UIAction(
                title: title,
                handler: { [unowned self] action in
                    if let persistedArticle {
                        realmManager.delete(article: persistedArticle)
                    } else {
                        realmManager.add(article: article)
                    }
                }
            )
            return UIMenu(children: [favAction])
        })
    }
    
}
