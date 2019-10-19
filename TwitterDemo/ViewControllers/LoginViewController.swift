//
//  LoginViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/6/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    private let accountService = AccountService()

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.isHidden = true

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if accountService.isLoggedIn() {
            let containerViewController = ContainerViewController()
            UIApplication.shared.keyWindow?.rootViewController = containerViewController
        } else {
            loginButton.isHidden = false
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        accountService.delegate = self
        accountService.login()
    }
}

extension LoginViewController: TwitterClientDelegate {
    func didLoggedIn() {
        if accountService.isLoggedIn() {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.homeViewController()
        }
    }
}
