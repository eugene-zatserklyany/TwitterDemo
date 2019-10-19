//
//  AppDelegateCoordinator.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/6/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

extension AppDelegate {
    func homeViewController() {
        guard let containerViewController = UIStoryboard.containerViewController() else { return }

        user.verifyCredentials { [weak self] (user) in
            let loggedUser = UserViewModel(user: user)
            self?.loggedUser = loggedUser
            containerViewController.loggedUser = UserViewModel(user: user)
            UIApplication.shared.keyWindow?.rootViewController = containerViewController
        }
    }

    func loginViewController() {
        let loginViewController = LoginViewController()
        UIApplication.shared.keyWindow?.rootViewController = loginViewController
    }
}


