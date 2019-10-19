//
//  ReplyButton2.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/17/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ReplyButton2: UIButton {

    var buttonTapped: (() -> ())?

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(didPressed), for: .touchUpInside)
        setupButtonAttributes()
    }

    private func setupButtonAttributes() {

        setTitle("Tweet your reply", for: [])
        setTitleColor(.white, for: [])
        contentHorizontalAlignment = .left
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        self.backgroundColor = .clear
    }

    @objc private func didPressed() {
        buttonTapped?()
    }
}
