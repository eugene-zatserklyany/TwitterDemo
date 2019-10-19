//
//  MediaView.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/8/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class MediaView: UIView {

    @IBOutlet private var mediaImageViews: [UIImageView]!
    @IBOutlet var imagesSpacingConstraints: [NSLayoutConstraint]!
    
    private var gestureRecorgonizers = [UITapGestureRecognizer]()
    private var imagesArray: [UIImage]! {
        willSet {
            guard let images = newValue, isImageTapped else { return }
            for i in 0..<images.count {
                if images[i] != UIImage.placeholder() {
                    imageUpdated?(images[i], i)
                }
            }
        }
    }
    
    private var isImageTapped: Bool = false

    var imageViewTapped: (([UIImage], Int) -> ())?
    var imageUpdated: ((UIImage, Int) -> ())?

    let size: Size
    
    init(size: MediaView.Size, imageCount: Int) {
        self.size = size
        super.init(frame: size.frame)
        
        imagesArray = [UIImage](repeating: UIImage.placeholder(), count: imageCount)
        guard let nib = loadNib(imageCount: imageCount) else { return }
        
        nib.frame = size.frame
        self.addSubview(nib)
        
        xibSetup()
        addGestureRecorgonizers()
    }

    func addGestureRecorgonizers() {
        mediaImageViews.forEach { (imageView) in
            let gestureRecorgonizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
            gestureRecorgonizers.append(gestureRecorgonizer)
            imageView.addGestureRecognizer(gestureRecorgonizer)
            imageView.isUserInteractionEnabled = true
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func xibSetup() {
        constraintsSetup()
        
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.backgroundColor = .magenta
    }
    
    private func constraintsSetup() {
        let heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: frame.height)
        let widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: frame.width)
        self.addConstraints([heightConstraint, widthConstraint])
        
        if size == .small {
            imagesSpacingConstraints?.forEach { $0.constant = 2 }
        }
    }

    func clearImageViews() {
        mediaImageViews.forEach { $0.image = nil }
    }
    
    func setupMedia(imageURLs: [URL]) {
        for i in 0..<imageURLs.count {
            UIImage.loadImage(from: imageURLs[i]) { [weak self] (image) in
                guard let image = image else { return }
                self?.mediaImageViews[i].image = image
                self?.imagesArray[i] = image
            }
        }
    }

    @objc func imageViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        print("Tapped")
        isImageTapped = true

        if let index = gestureRecorgonizers.index(of: gestureRecognizer) {
            let i = Int(index)
            imageViewTapped?(imagesArray, i)
        }

    }
}

extension MediaView {
    private func loadNib(imageCount: Int) -> UIView? {

        if imageCount < 1 && imageCount > 4 {
            fatalError("images count error")
        }

        let name = "Media\(imageCount)"
        let nib = UINib(nibName: name, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}

extension MediaView {
    enum Size: Equatable {
        case big(_ size: CGSize)
        case small
        
        var frame: CGRect {
            switch self {
            case .big(let size):
                return CGRect(x: 0, y: 0, width: size.width, height: size.width / 4 * 3)
            case .small:
                return CGRect(x: 0, y: 0, width: 100, height: 100)
            }
        }
    }
}
