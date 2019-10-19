//
//  UserCell.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/26/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var profileImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        descriptionTextView.isEditable = false

        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.image = nil
    }
    
    func setupUser(name: String, username: String, description: String) {
        nameLabel.text = name
        usernameLabel.text = username
        descriptionTextView.text = description
        
        descriptionTextView.isHidden = description == "" ? true : false
    }
    
    func setupProfileImage(_ imageURL: URL?) {
        profileImageView.loadImage(from: imageURL)
    }
}
