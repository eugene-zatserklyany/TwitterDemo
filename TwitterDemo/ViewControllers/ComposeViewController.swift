//
//  ComposeViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 4/7/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

protocol ComposeViewControllerProtocol {
    func tweetPublished(tweet: TweetModel)
}

class ComposeViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    public var tweetVM: TweetViewModel?
    private let tweetService = TweetService()

    public var loggedUser: UserViewModel? {
        didSet {
            observer = loggedUser?.observe(\UserViewModel.userProfileImage, options: [.new], changeHandler: { [weak self] (userVM, image) in
                guard let profileImage = image.newValue, let cell = self?.composeCell() else { return }
                cell.setupProfileImage(profileImage)
            })
        }
    }
    
    var delegate: ComposeViewControllerProtocol?
    private let tweetButton = UIButton(type: .custom)
    
    private var pickedImages = [UIImage]()
    private var keyboardHeight: CGFloat = 0
    private var observer: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ComposeCell.register(for: tableView)
        ReplyingCell.register(for: tableView)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        loggedUser = appDelegate?.loggedUser
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
        composeCell()?.hideKeyboard()
    }
    
    @objc private func cancelCompose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func publishTweet(_ sender: UIButton) {
        guard let attachments = createTweet() else { return }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        tweetService.publishTweet(with: attachments, success: { (data) in
            TweetModel.make(data: data, success: { [weak self] (value) in
                self?.delegate?.tweetPublished(tweet: value as! TweetModel)
                self?.dismiss(animated: true, completion: nil)
                }, failure: { (error) in
                    print("TweetModel.make error - ", error)
                    self.dismiss(animated: true, completion: nil)
            })
        }, failure: { (error) in
            print("error - ", error)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func createTweet() -> TweetAttachmets? {
        guard let text = composeCell()?.messageText() else {
            alertViewController(with: .message)
            return nil
        }

        let message = tweetVM?.composeMessage(replyWith: text) ?? text
        
        let attachments = TweetAttachmets(text: message, id: tweetVM?.tweetId())
        pickedImages.forEach { image in
            if let binaryImage = UIImage.binaryImage(image) {
                attachments.addMedia(binary: binaryImage)
            }
        }
        return attachments
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    private func setupUI() {
        navBarSetup()
        activityIndicator.isHidden = true
        
        if isItReply() {
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.tableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
            }
        } else {
            tableView.isScrollEnabled = false
        }
    }
    
    private func navBarSetup() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelCompose(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        
        let title = NSAttributedString(string: "Tweet", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.white])
        tweetButton.setAttributedTitle(title, for: [])
        tweetButton.setTitleColor(.white, for: [])
        tweetButton.backgroundColor = .blue
        tweetButton.frame.size = CGSize(width: 70, height: 0)
        tweetButton.layer.cornerRadius = 15
        tweetButton.clipsToBounds = true
        
        tweetButton.addTarget(self, action: #selector(publishTweet(_:)), for: .touchUpInside)
        
        let rightBarButton = UIBarButtonItem(customView: tweetButton)
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func tweetButtonState(shouldEnable: Bool) {
        let color: UIColor = shouldEnable ? .skyBlue : .blue
        tweetButton.backgroundColor = color
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tweetButton)
    }
    
    private func composeCell() -> ComposeCell? {
        return tableView.cellForRow(at: composeCellIndexPath()) as? ComposeCell
    }
    
    private func composeCellIndexPath() -> IndexPath {
        return IndexPath(row: isItReply() ? 1 : 0, section: 0)
    }
    
    private func isItReply() -> Bool {
        return tweetVM != nil ? true : false
    }
    
    private func setPlaceholder() -> ComposeCell.TweetPlaceholder {
        if isItReply() {
            return tweetVM?.user().username() == loggedUser?.username() ? .addAnoterTweet : .tweetYourReply
        }
        return .newTweet
    }
    
    private func alertViewController(with error: ImageError) {
        let alertController = UIAlertController.alertViewController(with: error)
        present(alertController, animated: true)
    }
    
    private func alertViewController(with error: TweetError) {
        let alertController = UIAlertController.alertViewController(with: error)
        present(alertController, animated: true)
    }
}

extension ComposeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isItReply() ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tweetVM != nil && indexPath.row == 0 {
            let cell: ReplyingCell = ReplyingCell.dequeue(from: tableView)
            cell.setupCell(tweet: tweetVM!)
            return cell
        } else {
            let cell: ComposeCell = ComposeCell.dequeue(from: tableView)
            
            cell.setupProfileImage(loggedUser?.profileImage())
            cell.textViewPlaceholder(setPlaceholder())
            
            cell.changeTweetButtonState = { [weak self] shouldEnable in
                self?.tweetButtonState(shouldEnable: shouldEnable)
            }
            
            cell.pickImageTapped = { [weak self] in
                self?.pickImage()
            }
            
            cell.takePictureTapped = { [weak self] in
                self?.takePicture()
            }
                
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == composeCellIndexPath() {
            return tableView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension ComposeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            UIImage.isImageValid(image, success: { [weak self] in
                guard let self = self else { return }
                if self.pickedImages.count < 4 {
                    self.pickedImages.append(image)
                    print("image picked")
                    self.composeCell()?.addImage(image)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true) { [weak self] in
                        self?.alertViewController(with: .media)
                    }
                }
            }, failure: { [weak self] (error) in
                self?.dismiss(animated: true, completion: { [weak self] in
                    self?.alertViewController(with: error)
                })
            })
        }
        
    }
    
    private func pickImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true)
    }
    
    private func takePicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .camera
        
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true)
    }
}
