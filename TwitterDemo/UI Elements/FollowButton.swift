//
//  FollowButton.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 14.10.2019.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class FollowButton: UIButton {
    
    private var buttonState: FollowButtonState = .follow
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonAttributes()
    }
    
    func changeState(_ state: FollowButtonState) {
        if state == .follow {
            followState()
        } else {
            followingState()
        }
    }
    
    private func setupButtonAttributes() {

        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 2
    }
    
    func followingState() {
        setTitle("Following", for: [])
        setTitleColor(.white, for: [])
        backgroundColor = .blue
    }
    
    func followState() {
        setTitle("Follow", for: [])
        setTitleColor(.blue, for: [])
        backgroundColor = .white
    }
    
    enum FollowButtonState {
        case following
        case follow
    }
}
