//
//  HomeViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/26/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class HomeViewController: FeedViewController {

    let loadingBackgroundView = UIView(frame: UIScreen.main.bounds)
    private let accountButton = UIButton(type: .custom)
    var containerDelegate: HomeViewControllerDelegate?
    private var observer: NSKeyValueObservation?

    override var loggedUser: UserViewModel? {
        didSet {
            observer = loggedUser?.observe(\UserViewModel.userProfileImage, options: [.new], changeHandler: { [weak self] (userVM, image) in
                guard let profileImage = image.newValue else { return }
                self?.accountButton.setImage(profileImage, for: [])
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingScreen()
        navbarSetup()

        tweetsViewModel = TweetsViewModel.init(feedService: feedService)
        tweetsViewModel.feedRequest() { [weak self] in
            self?.tableView.reloadData()
            self?.animateLoadingScreen()
        }

        composeButton.buttonTapped = { [weak self] in
            self?.composeViewController(inReply: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containerDelegate?.shouldEnableGestureRecognizer(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl.endRefreshing()
        containerDelegate?.shouldEnableGestureRecognizer(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navController = navigationController as? CustomNavigationController {
            navController.shouldEnableGestures(false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let navController = navigationController as? CustomNavigationController {
            navController.shouldEnableGestures(true)
        }
    }
    
    private func animateLoadingScreen() {
        let animation = CAKeyframeAnimation(keyPath: "transform")
        animation.duration = 1
        
        let original = CATransform3DScale(view.layer.transform, 1, 1, 1)
        let smaller = CATransform3DScale(view.layer.transform, 0.8, 0.8, 0.8)
        let bigger = CATransform3DScale(view.layer.transform, 25, 25, 25)
        
        animation.values = [original, smaller, bigger]
        animation.keyTimes = [0, 0.8, 1]
        
        animation.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .easeOut)]
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        view.layer.mask?.add(animation, forKey: "maskAnimation")
        
        // logo mask background view animation
        UIView.animate(withDuration: 0.1,
                       delay: 0.8,
                       options: .curveEaseIn,
                       animations: { [weak self] in
            self?.loadingBackgroundView.alpha = 0
        }, completion: { [weak self] _ in
            UIApplication.shared.endIgnoringInteractionEvents()
            self?.navigationController?.navigationBar.isHidden = false
            self?.tabBarController?.tabBar.layer.zPosition = 0
            self?.loadingBackgroundView.removeFromSuperview()
            self?.view.layer.mask = nil
        })
    }

    @objc private func handleAccountButton() {
        containerDelegate?.toggleSideMenu()
    }
    
    override func reload(sender: UIRefreshControl) {
        tweetsViewModel.feedRequest(lastTweetId) { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
    
    private func showLoadingScreen() {
        navigationController?.view.backgroundColor = .blue
        navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
        
        let logoLayer = CALayer()
        logoLayer.contents = UIImage(named: "twitter_white_logo")!.cgImage
        logoLayer.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        let fr = UIScreen.main.bounds
        logoLayer.position = CGPoint(x: fr.width / 2, y: fr.height / 2)
        logoLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.layer.mask = logoLayer
        
        loadingBackgroundView.backgroundColor = .white
        view.addSubview(loadingBackgroundView)
        view.bringSubviewToFront(loadingBackgroundView)
    }
}

extension HomeViewController {
    
    //TODO: Relocate
    private func navbarSetup() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "DynamicBackground")
        tabBarController?.tabBar.barTintColor = UIColor(named: "DynamicBackground")
        
        let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
        let logoContainer = UIView(frame: rect)
        let logoImageView = UIImageView(image: UIImage(named: "title_icon"))
        logoImageView.frame = rect
        logoImageView.contentMode = .scaleAspectFit
        logoContainer.addSubview(logoImageView)
        
        navigationItem.titleView = logoContainer
        
        accountButton.setImage(UIImage(named: "placeholderUser"), for: [])
        accountButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        accountButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        accountButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        accountButton.addTarget(self, action: #selector(handleAccountButton), for: .touchUpInside)
        accountButton.layer.cornerRadius = accountButton.frame.width / 2
        accountButton.clipsToBounds = true
        let accountBarButton = UIBarButtonItem(customView: accountButton)
        
        navigationItem.leftBarButtonItem = accountBarButton
    }
}
