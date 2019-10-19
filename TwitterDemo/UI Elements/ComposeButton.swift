//
//  UIButton.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/3/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ComposeButton: UIButton {

    var buttonTapped: (() -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget()
        applyUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget()
        applyUI()
    }

    private func addTarget() {
        addTarget(self, action: #selector(didPressed), for: .touchUpInside)
    }

    @objc func didPressed() {
        buttonTapped?()
    }

    private func applyUI() {
        layer.cornerRadius = self.frame.height / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.masksToBounds = false
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
    }
}
