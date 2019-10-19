//
//  ContainerViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/8/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate {
    func toggleSideMenu()
    func shouldEnableGestureRecognizer(_ state: Bool)
}

class ContainerViewController: UIViewController {

    var loggedUser: UserViewModel?

    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var homeView: UIView!

    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var sideMenuOriginalCenter: CGPoint!
    private var mainViewOriginalCenter: CGPoint!
    private var distanceToSwipe: CGFloat {
        get {
            return view.frame.width * 0.2
        }
    }

    private let velocityToSwipe: CGFloat = 1500
    private var minAlpha: CGFloat {
        get {
            return traitCollection.userInterfaceStyle == .dark ? 1 : 0.35
        }
    }

    var isSideMenuOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let application = UIApplication.shared
        if !application.isIgnoringInteractionEvents {
            application.beginIgnoringInteractionEvents()
        }

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))

        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SideMenuSegue" {
            let sideMenuViewController = segue.destination as? SideMenuViewController
            sideMenuViewController?.loggedUser = loggedUser
        }

        if segue.identifier == "HomeSegue" {
            
            let tabBarController = segue.destination as? UITabBarController
            let homeNavigationController = tabBarController?.viewControllers?[0] as? UINavigationController
            let homeViewController = homeNavigationController?.topViewController as? HomeViewController
            
            let searchNavigationController = tabBarController?.viewControllers?[1] as? UINavigationController
            let searchViewController = searchNavigationController?.topViewController as? SearchViewController
            
            homeViewController?.loggedUser = loggedUser
            homeViewController?.containerDelegate = self
            
            searchViewController?.loggedUser = loggedUser
            
//            if let tabBarController = segue.destination as? UITabBarController {
//                if let navController = tabBarController.viewControllers?[0] as? UINavigationController {
//                    if let homeViewController = navController.topViewController as? HomeViewController {
//                        homeViewController.loggedUser = loggedUser
//                        homeViewController.containerDelegate = self
//                    }
//                }
//                
//                if let navController = tabBarController.viewControllers?[1] as? UINavigationController {
//                    if let searchController = navController.topViewController as? SearchViewController {
//                        searchController.loggedUser = loggedUser
//                    }
//                }
//            }
        }
    }

    @objc func handlePanGestureRecognizer(_ recognizer: UIPanGestureRecognizer) {

        if recognizer.state == .began {
            sideMenuOriginalCenter = sideMenuView.center    //TODO: fix. Sometimes sideMenuView is nil
            mainViewOriginalCenter = homeView.center
        }

        if recognizer.state == .changed {

            if let _ = recognizer.view {

                let translationX = recognizer.translation(in: view).x
                let velocity = recognizer.velocity(in: view).x

                changeOpacity()
                if translationX > distanceToSwipe || velocity > velocityToSwipe {
                    isSideMenuOpen = true
                } else if translationX < -distanceToSwipe || velocity > velocityToSwipe {
                    isSideMenuOpen = false
                }

                let sideMenuCenter = sideMenuOriginalCenter.x + translationX
                let halfSideMenuWidth = sideMenuView.frame.width / 2

                let homeViewCenter = mainViewOriginalCenter.x + translationX
                let halfMainViewWidth = homeView.frame.width / 2

                let maxX = view.frame.maxX
                let minX = view.frame.minX

                if homeViewCenter + halfMainViewWidth < maxX {
                    homeView.center.x = maxX - halfMainViewWidth
                } else {
                    homeView.center.x = homeViewCenter
                }

                if sideMenuCenter - halfSideMenuWidth > minX {
                    sideMenuView.center.x = halfSideMenuWidth
                    homeView.center.x =  sideMenuView.frame.maxX + halfMainViewWidth
                } else {
                    sideMenuView.center.x = sideMenuCenter
                }
            }
        }

        if recognizer.state == .ended {
            self.didEndGesture(isSideMenuOpen)
        }
    }

    private func changeOpacity() {
        if traitCollection.userInterfaceStyle == .light {
            let coeff = (1 / (sideMenuView.frame.width)) * homeView.frame.origin.x * 0.65
            homeView.alpha = 1 - coeff
            sideMenuView.alpha = minAlpha + coeff
        }
    }

    private func didEndGesture(_ isSideMenuOpen: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if isSideMenuOpen {
                self.sideMenuView.frame.origin.x = 0
                self.homeView.frame.origin.x = self.sideMenuView.frame.width
                self.homeView.alpha = self.minAlpha
                self.sideMenuView.alpha = 1
            } else {
                self.sideMenuView.frame.origin.x = -self.sideMenuView.frame.width
                self.homeView.frame.origin.x = 0
                self.homeView.alpha = 1
                self.sideMenuView.alpha = self.minAlpha
            }
        }
    }
}

extension ContainerViewController: HomeViewControllerDelegate {
    func toggleSideMenu() {
        isSideMenuOpen.toggle()
        didEndGesture(isSideMenuOpen)
    }
    
    func shouldEnableGestureRecognizer(_ state: Bool) {
        panGestureRecognizer.isEnabled = state
        
        if isSideMenuOpen {
            toggleSideMenu()
        }
    }
}
