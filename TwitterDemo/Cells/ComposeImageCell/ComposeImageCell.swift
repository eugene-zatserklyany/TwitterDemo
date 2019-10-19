//
//  ComposeImageCell.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 11.10.2019.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ComposeImageCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var closeButton: UIButton!
    
    var closeTapped: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        closeButton.layer.cornerRadius = closeButton.frame.width / 2
        closeButton.clipsToBounds = true
    }
    
    func setupImage(_ image: UIImage) {
        imageView.image = image
    }

    @IBAction func close(_ sender: UIButton) {
        closeTapped?()
    }
}
