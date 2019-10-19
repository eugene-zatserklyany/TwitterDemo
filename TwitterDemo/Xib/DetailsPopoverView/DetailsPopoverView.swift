//
//  DetailsPopoverView.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 8/1/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

protocol DetailsPopoverDelegate {
    func tweetDeleted(_ tweet: TweetViewModel)
    func deleteAlertConroller(_ tweet: TweetViewModel)
}

class DetailsPopoverView: UIView {

    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteTweetButton: UIButton!
    
    var tweet: TweetViewModel?
    var delegate: DetailsPopoverDelegate?
    
    private var tweetService = TweetService()
    
    private var initialTargetPosition: CGFloat = 0
    private let velocityToSwipe: CGFloat = 1500
    private var distanceToSwipe: CGFloat {
        get {
            return self.frame.height * 0.85
        }
    }
    
    private var shouldClose: Bool = false
    
    init(frame: CGRect, tweet: TweetViewModel) {
        super.init(frame: frame)
        
        guard let view = loadFromNib() else { return }
        view.frame = frame
        addSubview(view)
        
        self.tweet = tweet
        
        viewsSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        animateCenterPanelYPosition(targetPosition: self.frame.maxY, isOpening: false) { (_) in
            self.removeFromSuperview()
        }
    }
    @IBAction func deleteTweetAction(_ sender: UIButton) {
        guard let tweet = tweet else { return }
        delegate?.deleteAlertConroller(tweet)
    }
    
    private func animatePopup(isClosing: Bool) {
        
        if !isClosing {
            animateCenterPanelYPosition(targetPosition: initialTargetPosition)
        } else {
            animateCenterPanelYPosition(targetPosition: self.frame.maxY, isOpening: false) { (_) in
                self.removeFromSuperview()
            }
        }
    }
    
    private func animateCenterPanelYPosition(targetPosition: CGFloat, isOpening: Bool = true, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.detailsView.frame.origin.y = targetPosition
            
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(isOpening ? 0.5 : 0.1)
        }, completion: completion)
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self).y
        
        if recognizer.state == .changed {
            
            detailsView.center.y = detailsView.center.y + recognizer.translation(in: self).y
            recognizer.setTranslation(CGPoint.zero, in: self)
            
            let detailsViewOriginY = detailsView.frame.origin.y
            
            if detailsViewOriginY > distanceToSwipe || velocity > velocityToSwipe {
                shouldClose = true
            } else {
                shouldClose = false
            }
        }
        
        if recognizer.state == .ended {
            animatePopup(isClosing: shouldClose)
        }
    }
    
    @objc func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.view != detailsView {
            animatePopup(isClosing: true)
        }
    }
    
    private func viewsSetup() {
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        detailsView.frame = CGRect(x: 0, y: frame.maxY, width: frame.width, height: frame.height)
        detailsView.layer.cornerRadius = 20
        detailsView.clipsToBounds = true
        detailsView.translatesAutoresizingMaskIntoConstraints = true
        
        animateCenterPanelYPosition(targetPosition: frame.size.height * 0.7) { (_) in
            self.initialTargetPosition = self.detailsView.frame.origin.y
        }
        
        cancelButton.layer.cornerRadius = 20
        cancelButton.clipsToBounds = true
        
        deleteTweetButton.setImage(#imageLiteral(resourceName: "delete"), for: [])
        deleteTweetButton.imageView?.contentMode = .scaleAspectFit
        deleteTweetButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        let tapGestureRecorgonizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(gestureRecognizer)
        addGestureRecognizer(tapGestureRecorgonizer)
        tapGestureRecorgonizer.delegate = self
    }
}

extension DetailsPopoverView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: detailsView))! {
            return false
        }
        return true
    }
}
