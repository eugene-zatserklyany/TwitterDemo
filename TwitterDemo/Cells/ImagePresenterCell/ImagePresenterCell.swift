//
//  ImagePresenterCell.swift
//  TwitterDemo
//
//  Created by Eugene on 5/27/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ImagePresenterCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    func setupImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func setupImageURL(_ imageURL: URL?) {
        imageView.loadImage(from: imageURL)
    }
}
