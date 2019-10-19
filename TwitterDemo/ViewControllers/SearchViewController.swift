//
//  SearchViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 15.10.2019.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var loggedUser: UserViewModel?

    private let searchController = UISearchController(searchResultsController: nil)
    private let searchService = SearchService()
    private var usersViewModel: UsersViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        usersViewModel = UsersViewModel(searchService: searchService)
        UserCell.register(for: tableView)
        navBarSetup()
    }

    private func navBarSetup() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "DynamicBackground")
        tabBarController?.tabBar.barTintColor = UIColor(named: "DynamicBackground")
        view.backgroundColor = UIColor(named: "DynamycBasicBackground")
        
        searchController.searchBar.placeholder = "Search Twitter"
        searchController.searchResultsUpdater = self
        definesPresentationContext = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func isSearchBarEmpty() -> Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private func userProfileViewController(user: UserViewModel) {
        guard let profileViewController = UIStoryboard.profileViewController() else { return }
        profileViewController.user = user
        profileViewController.loggedUser = loggedUser
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }

}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard !isSearchBarEmpty() else { return }
        guard let keyword = searchController.searchBar.text else { return }
        
        usersViewModel.searchRequest(keyword: keyword) { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserCell = UserCell.dequeue(from: tableView)
        usersViewModel.index = indexPath.row
        let user = usersViewModel.user
        cell.setupUser(name: user.name(), username: user.username(), description: user.descrtiption())
        cell.setupProfileImage(user.profileImageUrl())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        usersViewModel.index = indexPath.row
        let user = usersViewModel.user
        
        userProfileViewController(user: user)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
