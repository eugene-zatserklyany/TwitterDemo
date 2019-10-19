//
//  User.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/26/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class UserViewModel: NSObject {

    private var user: UserModel
    @objc dynamic var userProfileImage: UIImage?
    @objc dynamic var userProfileImageBigger: UIImage?
    var isFollowing: Bool?
    
    init(user: UserModel) {
        self.user = user
        super.init()
        
        loadProfileImage { [weak self] (image) in
            self?.userProfileImage = image
        }
        
        loadProfileImage(bigger: true, completion: { [weak self] (image) in
            self?.userProfileImageBigger = image
        })
    }

    func id() -> String {
        return user.id
    }

    func name() -> String {
        return user.name
    }

    func username() -> String {
        return "@" + user.screenName
    }

    func descrtiption() -> String {
        return user.description
    }
    
    func location() -> String? {
        return user.location
    }
    
    func link(isShorten: Bool = true) -> String? {
        let url = user.entities?.urls?.first
        return isShorten ? url?.shortUrl : url?.expandedURl
    }

    func followersCount() -> Int {
        return user.followersCount
    }

    func friendsCount() -> Int {
        return user.friendsCount
    }
    
    func isLoggedUser(id loggedUserId: String) -> Bool {
        return loggedUserId == id() ? true : false
    }

    func profileImage(isBigger: Bool = false) -> UIImage? {
        return isBigger ? userProfileImageBigger : userProfileImage
    }
    
    func profileImageUrl() -> URL? {
        return URL(string: user.profileImageUrl)
    }
    
    func userProfileBanner(completion: @escaping (UIImage?) -> ()) {
        guard let urlString = user.profileBannerUrl else { return }
        let url = URL(string: urlString)
        UIImage.loadImage(from: url) { (image) in
            completion(image)
        }
    }
    
    func joiningDate() -> String {
        return "Joined \(String.formatUserDate(dateString: user.date))"
    }

    private func loadProfileImage(bigger: Bool = false, completion: @escaping (UIImage?) -> ()) {
        let url = URL(string: bigger ? profileImageBigUrl() : user.profileImageUrl)
        UIImage.loadImage(from: url) { (image) in
            completion(image)
        }
    }
    
    private func profileImageBigUrl() -> String {
        return user.profileImageUrl.replacingOccurrences(of: "_normal", with: "")
    }
}
