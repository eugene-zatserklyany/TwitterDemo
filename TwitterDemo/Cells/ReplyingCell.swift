//
//  ReplyingCell.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 8/13/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ReplyingCell: UITableViewCell {
    
    @IBOutlet weak fileprivate var profileImageView: UIImageView!
    @IBOutlet weak fileprivate var messageLabel: UILabel!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var userNameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    
    @IBOutlet weak fileprivate var mediaStackView: UIStackView!
    @IBOutlet weak fileprivate var replyingToLabel: UILabel!
    
    private var mediaView: MediaView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(5)
        context?.setLineCap(.round)
        context?.setStrokeColor(UIColor.gray.cgColor)
        context?.move(to: CGPoint(x: profileImageView.frame.midX, y: profileImageView.frame.maxY + 8))
        context?.addLine(to: CGPoint(x: profileImageView.frame.midX, y: replyingToLabel.frame.maxY))
        context?.strokePath()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let tmp = mediaStackView.arrangedSubviews.first(where: { $0 == mediaView }) {
            mediaStackView.removeArrangedSubview(tmp)
            tmp.removeFromSuperview()
        }
    }

    func setupCell(tweet: TweetViewModel) {
        profileImageView.loadImage(from: tweet.profileImageUrl(), placeholder: UIImage.placeholder())
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
