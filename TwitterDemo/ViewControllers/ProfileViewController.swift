//
//  ProfileViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 7/5/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class ProfileViewController: FeedViewController {
    
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var bannerImageView: UIImageView!
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerScreenName: UILabel!
    
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var linkTextView: UITextView!
    @IBOutlet private weak var creationDateLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    
    private var userService = UserService()
    
    private let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear)
    private let visualEffectView = UIVisualEffectView(effect: nil)
    
    fileprivate let offsetHeaderStop: CGFloat = -20
    fileprivate let offsetTableView: CGFloat = 40
    
    private var observer: NSKeyValueObservation?
    var user: UserViewModel? {
        didSet {
            observer = user?.observe(\UserViewModel.userProfileImageBigger, options: [.new], changeHandler: { [weak self] (userVM, image) in
                guard let profileImage = image.newValue else { return }
                self?.profileImageView.image = profileImage
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewsSetup()
        
        tweetsViewModel = TweetsViewModel(feedService: feedService, userID: user?.id())
        tweetsViewModel.userFeedRequest { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        animator.stopAnimation(true)
        super.viewDidDisappear(animated)
    }
    
    override func reload(sender: UIRefreshControl) {
        tweetsViewModel.userFeedRequest { [weak self] in
            self?.tableView.reloadData()
            sender.endRefreshing()
            self?.setFollowButton()
        }
    }
    
    @IBAction func followButtonPressed(_ sender: Any) {
        guard let user = user, let isFollowing = user.isFollowing else { return }
        userService.follow(userId: user.id(), unfollow: isFollowing, success: { [weak self] in
            self?.user?.isFollowing?.toggle()
            self?.followButton.changeState(!isFollowing ? .following : .follow)
        }, failure: { (error) in
            print(error)
        })
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func viewsSetup() {
        edgesForExtendedLayout = []
        backButton.setImage(UIImage(named: "back"), for: [])
        backButton.tintColor = .white
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.clipsToBounds = true
        
        setFollowButton()
        
        guard let user = user else { return }
        nameLabel.text = user.name()
        headerScreenName.text = user.name()
        usernameLabel.text = user.username()
        descriptionLabel.text = user.descrtiption()
        locationLabel.text = user.location()
        linkTextView.text = user.link()
        creationDateLabel.text = user.joiningDate()
        
        locationLabel.textColor = .gray
        creationDateLabel.textColor = .gray
        usernameLabel.textColor = .gray

        bannerImageView.backgroundColor = .blueImagePlaceholder
        
        user.userProfileBanner(completion: { [weak self] (image) in
            self?.bannerImageView.image = image
        })
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.borderWidth = 5
        profileImageView.layer.borderColor = UIColor.dynamicWhite.cgColor
        profileImageView.clipsToBounds = true
        profileImageView.image = user.profileImage(isBigger: true)
        
        tableView.contentInset = UIEdgeInsets(top: offsetTableView, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        
        bannerImageView.addSubview(visualEffectView)
        visualEffectView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: bannerImageView.frame.height)
        animator.addAnimations {
            self.visualEffectView.effect = UIBlurEffect(style: .regular)
        }
    }
    
    private func setFollowButton() {
        guard let user = user, let loggedUser = loggedUser, !user.isLoggedUser(id: loggedUser.id()) else { return }
        userService.friendship(sourceId: user.id(), targetId: loggedUser.id(), success: { [weak self] (isFollowing) in
            user.isFollowing = isFollowing
            self?.followButton.changeState(isFollowing ? .following : .follow)
            self?.followButton.isHidden = false
        }, failure: { (error) in
            print(error)
        })
    }
}

extension ProfileViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = -scrollView.contentOffset.y - offsetTableView
        
        let headerHeight: CGFloat = headerView.bounds.height
        let imageHeight = profileImageView.bounds.height
        
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        var headerStackTransform = CATransform3DIdentity
        
        if offsetY > 0 {
            let headerScaleFactor = offsetY / headerHeight
            let headerTranslation = ((headerHeight * (1.0 + headerScaleFactor)) - headerHeight)/2
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerTranslation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            animator.fractionComplete = min(1.0, offsetY/100)
            headerStackView.isHidden = true
        } else {
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(offsetHeaderStop, offsetY), 0)
            animator.fractionComplete = 0
            
            let avatarScaleFactor = max(-offsetTableView, offsetY) / imageHeight
            let translation = ((profileImageView.bounds.height * (1.0 - avatarScaleFactor)) - imageHeight) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, translation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 + avatarScaleFactor, 1.0 + avatarScaleFactor, 0)
            
            //HeaderLabel
            headerStackView.isHidden = false
            let offsetHeaderStackView: CGFloat = nameLabel.frame.origin.y + offsetTableView
            let headerStackTranslation = min(headerStackView.frame.height, -(offsetY + offsetHeaderStackView))
            headerStackTransform = CATransform3DTranslate(headerStackTransform, 0, -headerStackTranslation, 0)
            
            let fraction = -offsetY < offsetHeaderStackView ? 0 : min(1.0, -((offsetY + offsetHeaderStackView + 5)/100))
            animator.fractionComplete = min(1.0, fraction)
        }
        
        profileImageView.layer.transform = avatarTransform
        headerView.layer.transform = headerTransform
        headerStackView.layer.transform = headerStackTransform
    }
}

fileprivate enum FollowButtonState: String {
    case following = "Following"
    case follow = "Follow"
}
