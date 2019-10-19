//
//  UICollectionViewCell+ReuseIdentifier.swift
//  TwitterDemo
//
//  Created by Eugene on 5/27/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    class func register(for collectionView: UICollectionView) {
        let reuseIdentifier = String(describing: self)
        let cellNib = UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
        collectionView.register(cellNib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

extension UICollectionView {
    func dequeue<T>(for indexPath: IndexPath) -> T {
        let reuseId =  String(describing:T.self)
        guard
            let cell = dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath as IndexPath) as? T else {
                fatalError("Could not dequeue cell with identifier: \(reuseId)")
        }
        return cell
    }
}
