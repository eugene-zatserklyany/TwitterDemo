//
//  Colors.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/11/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UIColor {
    static let gray = UIColor(red: 102/255, green: 119/255, blue: 133/255, alpha: 1)
    static let lightGray = UIColor(red: 231/255, green: 236/255, blue: 240/255, alpha: 1)
    static let blue = UIColor(red: 42/255, green: 163/255, blue: 239/255, alpha: 1)
    static let skyBlue = UIColor(red: 42/255, green: 163/255, blue: 239/255, alpha: 1)
    static let blueImagePlaceholder = UIColor(red: 158/255, green: 209/255, blue: 246/255, alpha: 1)
    static let green = UIColor(red: 39/255, green: 189/255, blue: 103/255, alpha: 1)
    static let red = UIColor(red: 224/255, green: 41/255, blue: 96/255, alpha: 1)
    
    static let dynamicBackground = UIColor(named: "DynamicBackground")!
    
    static var dynamicWhite: UIColor {
        return returnColor(light: .white, dark: .dynamicBackground)
    }
    static var dynamicBlack: UIColor {
        return returnColor(light: .black, dark: .white)
    }

    private static func returnColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        } else {
            return light
        }
    }
}
