//
//  ImagePresenterView.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 7/23/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class ImagePresenterView: UIView {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var detailsButton: DetailsButton!
    @IBOutlet weak var replyButton: ReplyButton!
    @IBOutlet weak var retweetButton: RetweetButton!
    @IBOutlet weak var likeButton: LikeButton!
    @IBOutlet weak var shareButton: ShareButton!
    
    @IBOutlet weak var replyButton2: ReplyButton2!
    
    private var initialCollectionViewPosition: CGFloat = 0
    private var currentTargerPosition: CGFloat = 0
    private var initialBottomViewPosition: CGFloat = 0
    private var initialCloseButtonPosition: CGFloat = 0
    private let velocityToSwipe: CGFloat = 1500
    private var distanceToSwipe: CGFloat {
        get {
            return self.frame.height * 0.5
        }
    }
    
    typealias buttonClosure = (() -> ())?
    var detailsButtonTapped: buttonClosure
    var replyButtonTapped: buttonClosure
    var shareButtonTapped: buttonClosure
    
    private var shouldClose: Bool = false
    private var isTapped: Bool = false
    
    var tweetVM: TweetViewModel?
    
    var images: [UIImage]?
    var index: Int?
    
    private var tweetService = TweetService()
    
    init(frame: CGRect, tweet: TweetViewModel, images: [UIImage], index: Int) {
        super.init(frame: frame)

        guard let view = self.loadFromNib() else { return }
        view.frame = frame
        addSubview(view)
        
        self.tweetVM = tweet
        self.images = images
        self.index = index
        
        viewsSetup()
        buttonsTapped()
        animateView(isClosing: false)
        
        ImagePresenterCell.register(for: collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func imageSetup() {
        guard let images = images, images.count > 0, let index = index else { return }
        
        ImagePresenterCell.register(for: collectionView)
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    //MARK: - View Animations
    private func animateView(isClosing: Bool) {
        
        if !isClosing {
            animateImageCenterYPosition(targetPosition: initialCollectionViewPosition)
        } else {
            animateImageCenterYPosition(targetPosition: currentTargerPosition, isOpening: false) { (_) in
                self.removeFromSuperview()
            }
        }
    }
    
    private func animateImageCenterYPosition(targetPosition: CGFloat, isOpening: Bool = true, completion: ((Bool) -> ())? = nil) {//isOpening ? 0.5 : 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = UIColor.darkGray.withAlphaComponent(isOpening ? 0.99 : 0.01)
            
            if !isOpening {
                if self.collectionView.frame.origin.y == self.initialCollectionViewPosition {
                    self.collectionView.isHidden = true
                } else if self.collectionView.center.y > self.frame.midY {
                    self.collectionView.frame.origin.y = self.frame.maxY
                } else {
                    self.collectionView.frame.origin.y = -self.collectionView.frame.height
                }
                self.closeButton.isHidden = true
                self.bottomView.isHidden = true
            } else {
                self.collectionView.frame.origin.y = self.initialCollectionViewPosition
            }
            
            }, completion: completion)
    }
    
    private func animateSupplementaryViews(shouldHide: Bool) {
        UIView.animate(withDuration: 0.4, delay: 0, options: shouldHide ? .curveEaseIn : .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            if shouldHide {
                self.bottomView.frame.origin.y = self.frame.maxY
                self.closeButton.frame.origin.y = -(self.closeButton.frame.height)
            } else {
                self.bottomView.frame.origin.y = self.initialBottomViewPosition
                self.closeButton.frame.origin.y = self.initialCloseButtonPosition
            }
            }, completion: nil)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let velocity = abs(recognizer.velocity(in: self).y)
        
        if recognizer.state == .began {
            animateSupplementaryViews(shouldHide: true)
        }
        
        if recognizer.state == .changed {
            
            collectionView.center.y = collectionView.center.y + recognizer.translation(in: self).y
            recognizer.setTranslation(CGPoint.zero, in: self)
            
            let translation = abs((self.frame.height / 2) - collectionView.center.y)
            
            if translation > distanceToSwipe || velocity > velocityToSwipe {
                shouldClose = true
            } else {
                shouldClose = false
            }
            
            self.backgroundColor = UIColor.darkGray.withAlphaComponent(CGFloat(1 - (translation / 350)))
            currentTargerPosition = collectionView.frame.origin.y
        }
        
        if recognizer.state == .ended {
            animateView(isClosing: shouldClose)
            animateSupplementaryViews(shouldHide: false)
        }
    }
    
    //MARK: Actions
    @objc private func handleTapGesture(_ recognizer: UIPanGestureRecognizer) {
        isTapped = !isTapped
        animateSupplementaryViews(shouldHide: isTapped)
    }
    
    @objc private func handleLongPressGesture(_ recognizer: UILongPressGestureRecognizer) {
        shareButtonTapped?()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        animateImageCenterYPosition(targetPosition: currentTargerPosition, isOpening: false) { (_) in
            self.removeFromSuperview()
        }
    }
    
    @objc func replyToTweet() {
        replyButtonTapped?()
    }
    
    private func buttonsTapped() {
        likeButton.buttonTapped = { [weak self] in
            guard let self = self, let tweet = self.tweetVM else { return }
            tweet.like {
                self.likeButton.setupButton(tweet.favoriteCount(), tweet.isLiked())
            }
        }
        
        retweetButton.buttonTapped = { [weak self] in
            guard let self = self, let tweet = self.tweetVM else { return }
            tweet.retweet {
                self.retweetButton.setupButton(tweet.retweetCount(), tweet.isRetweeted())
            }
        }
        
        replyButton.buttonTapped = { [weak self] in
            self?.replyButtonTapped?()
        }
        
        shareButton.buttonTapped = { [weak self] in
            self?.shareButtonTapped?()
        }
        
        replyButton2.buttonTapped = { [weak self] in
            self?.replyButtonTapped?()
        }
        
        detailsButton.buttonTapped = { [weak self] in
            self?.detailsButtonTapped?()
        }
    }
    
    
    //MARK: - View Setup
    private func viewsSetup() {
        imageSetup()
        
        initialCollectionViewPosition = UIScreen.main.bounds.origin.y
        initialBottomViewPosition = UIScreen.main.bounds.height - bottomView.frame.height
        initialCloseButtonPosition = closeButton.frame.origin.y
        
        replyButton.defaultColor = .light
        retweetButton.defaultColor = .light
        likeButton.defaultColor = .light
        shareButton.defaultColor = .light
        detailsButton.defaultColor = .light
        
        bottomView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        
        closeButton.setImage(#imageLiteral(resourceName: "close").withRenderingMode(.alwaysOriginal), for: [])
        closeButton.backgroundColor = .clear
        
        nameLabel.textColor = .white
        userNameLabel.textColor = .lightGray
        dateLabel.textColor = .lightGray
        messageLabel.textColor = .white
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        animateImageCenterYPosition(targetPosition: initialCollectionViewPosition)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        tapGestureRecognizer.delegate = self
        longPressGestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(longPressGestureRecognizer)
        
        guard let tweet = tweetVM else { return }
        profileImageView.loadImage(from: tweet.profileImageUrl(), placeholder:  UIImage.placeholder())
        nameLabel.text = tweet.name()
        userNameLabel.text = tweet.username()
        dateLabel.text = tweet.date()
        messageLabel.text = tweet.message()
        
        likeButton.setupButton(tweet.favoriteCount(), tweet.isLiked())
        retweetButton.setupButton(tweet.retweetCount(), tweet.isRetweeted())
    }
}

extension ImagePresenterView: UITextFieldDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let bottom = (touch.view?.isDescendant(of: bottomView))!
        let close = (touch.view?.isDescendant(of: closeButton))!
        return (bottom || close) ? false : true
    }
}

extension ImagePresenterView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImagePresenterCell = collectionView.dequeue(for: indexPath)
        
        if let images = images {
            
            cell.setupImage(images[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width, height: self.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}

extension ImagePresenterView {
    func updateImage(image: UIImage, index: Int) {
        images?[index] = image
        collectionView?.reloadData()
    }
}
