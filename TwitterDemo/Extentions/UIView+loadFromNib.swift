
//
//  UIView+loadFromNib.swift
//  
//
//  Created by Eugene Zatserklyaniy on 8/3/19.
//

import UIKit

extension UIView {
    @discardableResult
    func loadFromNib<T: UIView>() -> T? {
        return Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T
    }
}
