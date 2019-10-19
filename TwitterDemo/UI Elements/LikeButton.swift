//
//  LikeButton.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/3/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class LikeButton: UIButton, TweetButtonProtocol {

    var buttonTapped: (() -> ())?
    var defaultColor: DefaultColor = .dark {
        didSet {
            setupButtonAttributes()
        }
    }

    override func awakeFromNib() {
        addTarget(self, action: #selector(didPressed), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonAttributes()
    }

    private func setupButtonAttributes() {
        let font: UIFont = defaultColor == .dark ? .systemFont(ofSize: 12) : .boldSystemFont(ofSize: 14)
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.font = font
        applyColor(forState: false, defaultColor: defaultColor)
    }

    func setupButton(_ likesCount: Int, _ isLiked: Bool) {
        applyColor(forState: isLiked, defaultColor: defaultColor)

        self.setTitle(String.likesCount(likesCount), for: [])
    }

    @objc private func didPressed() {
        buttonTapped?()
    }
}
