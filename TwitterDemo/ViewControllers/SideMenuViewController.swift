//
//  SideMenuViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/8/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    @objc public var loggedUser: UserViewModel?
    private var observer: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.image = UIImage(named: "placeholderUser")
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        tableView.isHidden = true
        usernameLabel.textColor = .gray
        logoutButton.setTitleColor(.red, for: [])

        setupUI()

        observer = loggedUser?.observe(\UserViewModel.userProfileImage, options: [.new], changeHandler: { (userVM, image) in
            guard let profileImage = image.newValue else { return }
            self.profileImageView.image = profileImage
        })
        
    }
    @IBAction func logout(_ sender: UIButton) {
        AppDelegate().logout()
    }
    
    private func setupUI() {
        guard let loggedUser = loggedUser else { return }
        nameLabel.text = loggedUser.name()
        usernameLabel.text = loggedUser.username()
        followingLabel.attributedText = attributedString(count: loggedUser.friendsCount(), text: "Followings")
        followersLabel.attributedText = attributedString(count: loggedUser.followersCount(), text: "Followers")

        guard let image = loggedUser.profileImage() else { return }
        profileImageView.image = image
    }

    private func attributedString(count: Int, text: String) -> NSAttributedString {
        let string = NSMutableAttributedString(string: "\(count) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.dynamicBlack])
        string.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.gray]))
        return string
    }
}
