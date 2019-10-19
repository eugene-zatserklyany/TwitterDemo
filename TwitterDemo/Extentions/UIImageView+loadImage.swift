//
//  UIImageView+loadImage.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/3/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

extension UIImageView {

    func loadImage(from imageURL: URL?, placeholder: UIImage = #imageLiteral(resourceName: "placeholderUser"), completion: ((UIImage) -> ())? = nil) {
        image = placeholder
        guard let imageURL = imageURL else {
            print("imageURL = nil")
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                guard let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {
                    self.image = image
                    completion?(image)
                }
            } catch let error {
                print("loadImage error: ", error)
            }
        }
    }
}

extension UIImage {
    
    static func placeholder() -> UIImage {
        return UIImage(named: "placeholderUser")!
    }

    static func loadImage(from imageURL: URL?, completion: @escaping (UIImage?) -> ()) {
        guard let imageURL = imageURL else {
            print("imageURL = nil")
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = try Data(contentsOf: imageURL)
                let image = UIImage(data: data)

                DispatchQueue.main.async {
                    completion(image)
                }
            } catch let error {
                print("loadImage error: ", error)
            }
        }
    }
    
    static func binaryImage(_ image: UIImage) -> String? {
        let imageData = image.jpegData(compressionQuality: 0.2)
        return imageData?.base64EncodedString(options: .lineLength64Characters)
    }
    
    static func isImageValid(_ image: UIImage, success: @escaping () -> (), failure: @escaping (ImageError) -> ()) {
        
        if !isDimentionsValid(image) {
            failure(.dimensions)
        } else if !isSizeValid(image) {
            failure(.size)
        } else {
            success()
        }
    }
    
    private static func isDimentionsValid(_ image: UIImage) -> Bool {
        let min: CGFloat = 4
        let max: CGFloat = 8192
        
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        print("🏞 image dimentions: \(widthInPixels) x \(heightInPixels)")
        
        let isValid = (widthInPixels > min && widthInPixels < max) && (heightInPixels > min && heightInPixels < max)
        return isValid ? true : false
    }
    
    private static func isSizeValid(_ image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return false }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        let string = formatter.string(fromByteCount: Int64(data.count))
        print("🏞 formatted result: \(string)")
        
        let isValid = (data.count < (4 * (1024 * 1024))) ? true : false
        return isValid
    }
}
