//
//  ComposeCell.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 8/13/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit

class ComposeCell: UITableViewCell {
    
    @IBOutlet weak fileprivate var profileImageView: UIImageView!
    @IBOutlet weak fileprivate var tweetTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let toolBar = UIToolbar()
    private var images = [UIImage]()
    
    var changeTweetButtonState: ((Bool) -> ())?
    var pickImageTapped: (() -> ())?
    var takePictureTapped: (() -> ())?

    
    lazy private var textViewPlaceholder: TweetPlaceholder = .newTweet
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        tweetTextView.delegate = self
        tweetTextView.textColor = UIColor.gray
        tweetTextView.backgroundColor = .clear
        tweetTextView.becomeFirstResponder()
        tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)
        textViewDidChange(tweetTextView)
        
        let pickImageButton = UIBarButtonItem(image: UIImage(named: "image"), style: .done, target: self, action: #selector(pickImage))
        let takePictureButton = UIBarButtonItem(image: UIImage(named: "camera"), style: .done, target: self, action: #selector(takePicture))
        let counter = UIBarButtonItem(title: "16", style: .plain, target: self, action: nil)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        toolBar.setItems([pickImageButton, takePictureButton, space, counter], animated: true)
        toolBar.sizeToFit()
        tweetTextView.inputAccessoryView = toolBar
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        ComposeImageCell.register(for: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        tweetTextView.becomeFirstResponder()
    }

    func setupProfileImage(_ image: UIImage?) {
        profileImageView.image = image
    }
    
    func messageText() -> String? {
        if isTextValid() {
            return tweetTextView.text
        }
        return nil
    }
    
    func textViewPlaceholder(_ value: TweetPlaceholder ) {
        textViewPlaceholder = value
        tweetTextView.text = textViewPlaceholder.rawValue
    }
    
    func hideKeyboard() {
        tweetTextView.resignFirstResponder()
    }
    
    func addImage(_ image: UIImage) {
        images.append(image)
        collectionView.reloadData()
    }
    
    private func removeImage(at index: Int) {
        images.remove(at: index)
        collectionView.reloadData()
    }
    
    private func isTextValid() -> Bool {
        guard let text = tweetTextView.text else { return false}
        let textWithNoSpace = text.replacingOccurrences(of: " ", with: "")
        let isItPlacecolder = (text == textViewPlaceholder.rawValue && tweetTextView.textColor == .gray)
        return textWithNoSpace == "" || isItPlacecolder ? false : true
    }
    
    @objc private func pickImage() {
        pickImageTapped?()
    }
    
    @objc private func takePicture() {
        takePictureTapped?()
    }
    
    private func setCounter(count: Int) {
        let residualCharacters = 240 - count
        var color: UIColor
        if residualCharacters == 0 {
            color = .systemRed
        } else if residualCharacters <= 20 {
            color = .systemOrange
        } else {
            color = .systemBlue
        }
        
        toolBar.items?.last?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: color], for: .normal)
        toolBar.items?.last?.title = String(residualCharacters)
    }
}

extension ComposeCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        var newLength = 0
        
        if textView.textColor != .gray {
            newLength = textView.text.utf16.count + text.utf16.count - range.length
        }
        
        let currentText: String = tweetTextView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.count > 240 { return false}

        if updatedText.isEmpty {
            textView.text = textViewPlaceholder.rawValue
            textView.textColor = .gray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == .gray && !text.isEmpty {
            textView.textColor = .dynamicBlack
            textView.text = text
            newLength = text.utf16.count
        } else {
            setCounter(count: newLength)
            return true
        }
        
        changeTweetButtonState?(isTextValid())
        
        setCounter(count: newLength)
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
//        if view.window != nil {
            if textView.textColor == .gray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
//        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setCounter(count: 0)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height < 200 {
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                    tweetTextView.isScrollEnabled = false
                }
            }
        } else {
            tweetTextView.isScrollEnabled = true
        }
        
    }
}

extension ComposeCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ComposeImageCell = collectionView.dequeue(for: indexPath)
        
        if !images.isEmpty {
            cell.setupImage(images[indexPath.row])
        }
        
        cell.closeTapped = { [weak self] in
            self?.removeImage(at: indexPath.row)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.image = images[indexPath.item]
        imageView.sizeToFit()
        let factor = imageView.frame.height / collectionView.frame.height
        return CGSize(width: imageView.frame.width / factor, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension ComposeCell {
    enum TweetPlaceholder: String {
        case newTweet = "What's happening?"
        case addAnoterTweet = "Add another tweet"
        case tweetYourReply = "Tweet your reply"
    }
}
