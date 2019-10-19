//
//  UITableViewCell+ReuseIdentifier.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/27/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class func register(for tableView: UITableView) {
        let reuseIdentifier = String(describing: self)
        let cellNib = UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
        tableView.register(cellNib, forCellReuseIdentifier: reuseIdentifier)
    }

    class func dequeue<T: UITableViewCell>(from tableView: UITableView) -> T {
        let reuseIdentifier = String(describing: self)
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? T,
            type(of: cell) == self
        else {
            fatalError()
        }
        return cell
    }
}
