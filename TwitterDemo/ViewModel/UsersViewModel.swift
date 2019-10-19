//
//  UsersViewModel.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 15.10.2019.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import Foundation
import TwitterBusinessLayer

class UsersViewModel {
    
    private let searchService: SearchService
    private var users = [UserViewModel]()
    lazy var index = 0
    
    var user: UserViewModel {
        get {
            return users[index]
        }
    }

    var count: Int {
        get {
            return self.users.count
        }
    }
    
    init(searchService: SearchService) {
        self.searchService = searchService
    }
}

extension UsersViewModel {
    func searchRequest(keyword: String, success: @escaping () -> ()) {
        searchService.search(keyword: keyword, success: { [weak self] (users) in
            guard let self = self else { return }
            self.users = self.mapUsers(users: users)
            success()
        }, failure: { error in
            print(error)
        })
    }
    
    private func mapUsers(users: [UserModel]) -> [UserViewModel] {
        return users.map({ (userVM) -> UserViewModel in
            return UserViewModel(user: userVM)
        })
    }
}
