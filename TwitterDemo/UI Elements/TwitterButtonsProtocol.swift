//
//  TwitterButtonsProtocol.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/7/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

enum DefaultColor {
    case dark, light
}

protocol TweetButtonProtocol: class {
    ///Do not override this function
    func applyColor(forState isEnabled: Bool, defaultColor: DefaultColor)
}

extension TweetButtonProtocol where Self: RetweetButton {
    func applyColor(forState isEnabled: Bool, defaultColor: DefaultColor) {

        let disabledColor: UIColor = defaultColor == .dark ? .gray : .white
        let color: UIColor = isEnabled ? .green : disabledColor
        self.setTitleColor(color, for: [])
        self.tintColor = color
    }
}

extension TweetButtonProtocol where Self: LikeButton {
    func applyColor(forState isEnabled: Bool, defaultColor: DefaultColor) {

        let disabledColor: UIColor = defaultColor == .dark ? .gray : .white
        let color: UIColor = isEnabled ? .red : disabledColor
        self.setTitleColor(color, for: [])
        self.tintColor = color
    }
}
