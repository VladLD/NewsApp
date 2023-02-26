//
//  FiltersViewController.swift
//  NewsApp
//
//  Created by Vlad Lapchynskyi on 19.02.2023.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    typealias Completion = ([Source]) -> Void
    
    // MARK: - Outlets
    
    @IBOutlet private weak var saveBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var sources: [Source]!
    private var preselectedIndexPaths: [IndexPath]!
    private var completion: Completion?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK: - Internal methods
    
    func set(sources: [Source]) {
        self.sources = sources
    }
    
    func set(selectedSources: [Source]) {
        let selectedIndices = selectedSources.compactMap({ selectedSource in
            sources.firstIndex(where: { $0.id == selectedSource.id })
        })
        preselectedIndexPaths = selectedIndices.map({
            IndexPath(row: $0, section: 0)
        })
    }
    
    func set(completion: Completion?) {
        self.completion = completion
    }
    
    // MARK: - Private methods
    
    private func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: UITableViewCell.identifier
        )
        tableView.layer.cornerRadius = 16
        
        preselectSources()
    }
    
    private func preselectSources() {
        preselectedIndexPaths.forEach {
            tableView.selectRow(at: $0, animated: false, scrollPosition: .none)
        }
    }
    
    private func refreshSaveBarButtonItem() {
        let selectedRows = tableView.indexPathsForSelectedRows ?? []
        saveBarButtonItem.isEnabled = !selectedRows.isEmpty && selectedRows != preselectedIndexPaths
    }
    
    // MARK: - Selectors
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        let selectedRows = tableView.indexPathsForSelectedRows ?? []
        let selectedSources = selectedRows.map(\.row).map {
            sources[$0]
        }
        completion?(selectedSources)
        dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: UITableViewCell.identifier, for: indexPath
        )
        let source = sources[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        
        content.text = source.name
        content.secondaryText = source.description
        
        cell.contentConfiguration = content
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        refreshSaveBarButtonItem()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        refreshSaveBarButtonItem()
    }
    
}

