//
//  TweetReplyingTo.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 8/8/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class TweetReplyingTo: UIView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mediaStackView: UIStackView!
    @IBOutlet weak var replyingToLabel: UILabel!
    
    private var mediaView: MediaView!
    
    var tweet: TweetViewModel? {
        didSet {
            viewsSetup()
        }
    }


//    init(frame: CGRect, tweet: TweetViewModel) {
//        super.init(frame: frame)
//
//        guard let view = self.loadFromNib() else { return }
//        view.frame = frame
//        addSubview(view)
//        self.subviews.first?.backgroundColor = .clear
//
//        self.tweet = tweet
//
//        viewsSetup()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = self.loadFromNib() else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        view.backgroundColor = .clear
    }
    
    private func viewsSetup() {
        
        
        
        guard let tweet = tweet else { return }
        profileImageView.loadImage(from: tweet.profileImageUrl(), placeholder:  UIImage.placeholder())
        nameLabel.text = tweet.name()
        userNameLabel.text = tweet.username()
        dateLabel.text = tweet.date()
        messageLabel.text = tweet.message()
        
        let usernameAttributed = NSAttributedString(string: tweet.username(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.skyBlue])
        let attributedString = NSMutableAttributedString(string: "Replying to ")
        attributedString.append(usernameAttributed)
        replyingToLabel.attributedText = attributedString
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        if let mediaUrls = tweet.mediaURLs() {
            mediaView = MediaView(size: .small, imageCount: mediaUrls.count)
            mediaView.isUserInteractionEnabled = false
            mediaView.setupMedia(imageURLs: mediaUrls)
            mediaStackView.addArrangedSubview(mediaView)
        }
    }
    
}
