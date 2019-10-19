//
//  UIStoryboard.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/10/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func main() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: nil) }

    static func loginViewController() -> LoginViewController? {
        return main().instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
    }

    static func containerViewController() -> ContainerViewController? {
        return main().instantiateViewController(withIdentifier: "ContainerViewController") as? ContainerViewController
    }

    static func sideMenuViewController() -> SideMenuViewController? {
        return main().instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
    }

    static func homeViewController() -> HomeViewController? {
        return main().instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
    }

    static func composeViewController() -> ComposeViewController? {
        return main().instantiateViewController(withIdentifier: "ComposeViewController") as? ComposeViewController
    }
    
    static func composeNavigationController() -> UINavigationController? {
        return main().instantiateViewController(withIdentifier: "ComposeNavigationContoller") as? UINavigationController
    }
    
    static func profileViewController() -> ProfileViewController? {
        return main().instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
    }
}


extension UINavigationController {
    func shouldHide(_ hide: Bool) {
        self.navigationBar.isHidden = hide ? true : false
    }
}
