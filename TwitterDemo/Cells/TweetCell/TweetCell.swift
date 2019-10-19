//
//  TweetCell.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/26/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak fileprivate var profileImageView: UIImageView!
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var userNameLabel: UILabel!

    @IBOutlet weak fileprivate var messageLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!

    @IBOutlet weak fileprivate var mediaStackView: UIStackView!
    fileprivate var mediaView: MediaView!
    
    @IBOutlet weak var linksTextView: UITextView!
    
    @IBOutlet weak fileprivate var replyButton: ReplyButton!
    @IBOutlet weak fileprivate var retweetButton: RetweetButton!
    @IBOutlet weak fileprivate var likeButton: LikeButton!
    @IBOutlet weak fileprivate var shareButton: ShareButton!

    @IBOutlet weak var detailsButton: DetailsButton!

    typealias buttonClosure = (() -> ())?

    var detailsButtonTapped: buttonClosure
    var replyButtonTapped: buttonClosure
    var likeButtonTapped: buttonClosure
    var retweetButtonTapped: buttonClosure
    var shareButtonTapped: buttonClosure

    var imageViewTapped: (([UIImage], Int) -> ())?
    var imageUpdated: ((UIImage, Int) -> ())?
    
    var profileImageTapped: buttonClosure
    fileprivate var gestureRecognizer: UITapGestureRecognizer!

    override func awakeFromNib() {
        super.awakeFromNib()

        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        userNameLabel.textColor = .gray
        dateLabel.textColor = .gray
        linksTextView.isHidden = true
        
        buttonsTapped()
        profileImageGestureRecognizer()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        messageLabel.text = nil
        linksTextView.attributedText = nil
        linksTextView.isHidden = true
 
        if let tmp = mediaStackView.arrangedSubviews.first(where: { $0 == mediaView }) {
            mediaStackView.removeArrangedSubview(tmp)
            tmp.removeFromSuperview()
        }
    }
    
    @IBAction func detailsButtonTapped(_ sender: UIButton) {
        detailsButtonTapped?()
    }
    
    @IBAction func replyButtonTapped(_ sender: UIButton) {
        replyButtonTapped?()
    }
    
    private func buttonsTapped() {
        likeButton.buttonTapped = { [weak self] in
            self?.likeButtonTapped?()
        }
        
        retweetButton.buttonTapped = { [weak self] in
            self?.retweetButtonTapped?()
        }
        
        replyButton.buttonTapped = { [weak self] in
            self?.replyButtonTapped?()
        }
        
        shareButton.buttonTapped = { [weak self] in
            self?.shareButtonTapped?()
        }
        
        detailsButton.buttonTapped = { [weak self] in
            self?.detailsButtonTapped?()
        }
    }
    
    private func profileImageGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageAction))
        profileImageView.addGestureRecognizer(gestureRecognizer)
    }
}

extension TweetCell {
    func setupLikeButton(favCount: Int, isLiked: Bool) {
        likeButton.setupButton(favCount, isLiked)
    }

    func setupRetweetButton(retweetCount: Int, isRetweeted: Bool) {
        retweetButton.setupButton(retweetCount, isRetweeted)
    }

    func setupUser(name: String, username: String) {
        nameLabel.text = name
        userNameLabel.text = username
    }

    func setupProfileImage(_ imageURL: URL?) {
        profileImageView.loadImage(from: imageURL, placeholder: UIImage.placeholder())
    }

    func setupTweet(message: String, date: String) {
        messageLabel.text = message
        dateLabel.text = date
    }

    //MARK: - Media Setup
    private func mediaViewInit(_ count: Int) {
        let size = mediaStackView.frame.size
        mediaView = MediaView(size: .big(size), imageCount: count) //EXTRACT
        mediaStackView.addArrangedSubview(mediaView)
        mediaStackView.layoutIfNeeded()
    }
    
    func setupImageCount(_ count: Int) {
        mediaViewInit(count)
        mediaView.imageViewTapped = { [weak self] (images, index) in
            self?.imageViewTapped?(images, index)
        }
        
        mediaView.imageUpdated = { [weak self] (image, index) in
            self?.imageUpdated?(image, index)
        }
    }
    
    func setupMedia(imageURLs: [URL]) {
        mediaView.setupMedia(imageURLs: imageURLs)
    }
    
    //MARK: - Links setup
    
    func setupLinks(links: [String], shortLinks: [String]) {        
        let linksAttributedString = NSMutableAttributedString()

        for i in 0..<links.count {
            guard !links[i].isEmpty else { return }
            let attributedString = NSMutableAttributedString(string: shortLinks[i])
            let range = NSRange(location: 0, length: shortLinks[i].count)
            attributedString.addAttribute(.link, value: links[i], range: range)
            attributedString.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)], range: range)

            if i > 0 {
                attributedString.insert(NSAttributedString(string: "\n"), at: 0)
            }

            linksAttributedString.append(attributedString)
        }

        linksTextView.attributedText = linksAttributedString
        linksTextView.isHidden = false
    }
    
    private func estimatedHeightForText(_ text: NSAttributedString) -> CGFloat {

        let size = CGSize(width: mediaStackView.frame.width, height: 1000)
        let estimatedFrame = text.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)  //nsstring drawning context
        return estimatedFrame.height
    }
    
    //MARK: - ProfileImage Action
    @objc private func profileImageAction() {
        profileImageTapped?()
    }
}
