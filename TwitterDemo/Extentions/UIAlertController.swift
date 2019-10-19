//
//  UIAlertController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 11.10.2019.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    private static func showAlertController(title: String, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    static func alertViewController(with error: ImageError) -> UIAlertController {
        let title = "You can't upload this image"

        var message: String?
        
        switch error {
        case .dimensions:
            message = "Image's dimention doesn't match Twitter's API"
        case .size:
            message = "Image's size is too big, try another image"
        }
        return UIAlertController.showAlertController(title: title, message: message)
    }
    
    static func alertViewController(with error: TweetError) -> UIAlertController {
        
        var title: String
        var message: String
        
        switch error {
        case .message:
            title = "Nothing to Tweet"
            message = "Write a message"
        case .media:
            title = "Too many images"
            message = "Pick up to 4 images"
        }
        return UIAlertController.showAlertController(title: title, message: message)
    }
}

enum ComposeTweetError {
    case tweetError
    case imageError
}

enum TweetError {
    case message
    case media
}

enum ImageError {
    case dimensions
    case size
}
