//
//  ShareButton.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/14/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ShareButton: UIButton {

    var buttonTapped: (() -> ())?
    var defaultColor: DefaultColor = .dark {
        didSet {
            setupButtonAttributes()
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action: #selector(didPressed), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButtonAttributes()
    }

    private func setupButtonAttributes() {
        let color: UIColor = defaultColor == .dark ? .gray : .white
        self.imageView?.contentMode = .scaleAspectFit
        self.tintColor = color
    }

    @objc private func didPressed() {
        buttonTapped?()
    }
}
