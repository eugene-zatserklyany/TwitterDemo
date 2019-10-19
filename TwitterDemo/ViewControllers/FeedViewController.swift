//
//  FeedViewController.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 10/8/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import UIKit
import TwitterBusinessLayer

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeButton: ComposeButton!
    
    private var accountService = AccountService()
    private var tweetService = TweetService()
    internal var feedService = FeedService()
    
    public var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(reload(sender:)), for: .valueChanged)
        control.tintColor = .blue
        return control
    }()
    
    var loggedUser: UserViewModel?
    
    var lastTweetId: String?
    private var letDataLoading: Bool = true {
        didSet {
            if letDataLoading {
                letDataLoading.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                    self?.letDataLoading.toggle()
                }
            }
        }
    }
        
    var imagePresenter: ImagePresenterView?
    var detailsPopover: DetailsPopoverView?
    
    var tweetsViewModel: TweetsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellRegistration()
        tableView.refreshControl = refreshControl
        
        tweetsViewModel = TweetsViewModel.init(feedService: feedService)
        composeButton.buttonTapped = { [weak self] in
            self?.composeViewController(inReply: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshControl.endRefreshing()
    }
    
    @objc public func reload(sender: UIRefreshControl) {}
    
    private func cellRegistration() {
        UserCell.register(for: tableView )
        TweetCell.register(for: tableView)
    }
    
    private func imagePresenter(tweet: TweetViewModel, images: [UIImage], index: Int) {
        imagePresenter = ImagePresenterView(frame: UIScreen.main.bounds, tweet: tweet, images: images, index: index)
        guard let imagePresenter = imagePresenter else { return }
        tabBarController?.view.addSubview(imagePresenter)
        
        imagePresenter.shareButtonTapped = { [weak self] in
            self?.shareButton(tweet: tweet)
        }
        
        imagePresenter.replyButtonTapped = { [weak self] in
            self?.composeViewController(inReply: tweet)
        }
        
        imagePresenter.detailsButtonTapped = { [weak self] in
            self?.detailsPopover(tweet: tweet)
        }
    }
    
    private func detailsPopover(tweet: TweetViewModel) {
        detailsPopover = DetailsPopoverView(frame: UIScreen.main.bounds, tweet: tweet)
        guard let detailsPopover = detailsPopover else { return }
        detailsPopover.delegate = self
        tabBarController?.view.addSubview(detailsPopover)
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetsViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TweetCell = TweetCell.dequeue(from: tableView)
        tweetsViewModel.index = indexPath.row
        let tweet = tweetsViewModel.tweet
        
        cell.setupUser(name: tweet.name(), username: tweet.username())
        cell.setupTweet(message: tweet.message(), date: tweet.date())
        
        cell.setupProfileImage(tweet.profileImageUrl())
        
        cell.setupLikeButton(favCount: tweet.favoriteCount(), isLiked: tweet.isLiked())
        cell.setupRetweetButton(retweetCount: tweet.retweetCount(), isRetweeted: tweet.isRetweeted())
        
        if let mediaUrls = tweet.mediaURLs() {
            cell.setupImageCount(mediaUrls.count)
            cell.setupMedia(imageURLs: mediaUrls)
        }
        
        if let links = tweet.urls(isShorten: false), let shortLinks = tweet.urls()  {
            if links.count == shortLinks.count {
                cell.setupLinks(links: links, shortLinks: shortLinks)
            }
        }
        
        cell.likeButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.likeButton(tweet: tweet, indexPath: indexPath)
        }
        
        cell.retweetButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.retweetButton(tweet: tweet, indexPath: indexPath)
        }
        
        cell.replyButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.composeViewController(inReply: tweet)
        }
        
        cell.shareButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.shareButton(tweet: tweet)
        }
        
        cell.imageViewTapped = { [weak self] (images, index) in
            guard let self = self else { return }
            self.imagePresenter(tweet: tweet, images: images, index: index)
        }
        
        cell.imageUpdated = { [weak self] (image, index) in
            guard let imagePresenter = self?.imagePresenter else { return }
            imagePresenter.updateImage(image: image, index: index)
        }
        
        cell.detailsButtonTapped = { [weak self] in
            guard let self = self else { return }
            if let loggedUser = self.loggedUser, tweet.user().id() == loggedUser.id() {
                self.detailsPopover(tweet: tweet)
            }
        }
        
        cell.profileImageTapped = { [weak self] in
            guard let self = self else { return }
            self.userProfileViewController(user: tweet.user())
            print("ProfileImage tapped")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        tableView.backgroundColor = .lightGray
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension FeedViewController {
    
    private func likeButton(tweet: TweetViewModel, indexPath: IndexPath) {
        tweet.like() { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private func retweetButton(tweet: TweetViewModel, indexPath: IndexPath) {
        tweet.retweet() { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private func shareButton(tweet: TweetViewModel) {
        guard let tweetUrl = tweet.link() else { return }
        let items = [tweetUrl]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard tweetsViewModel.count > 0 && letDataLoading else { return }
        let tableViewHeightAboveScreen = tableView.contentSize.height - tableView.bounds.size.height
        if scrollView.contentOffset.y > tableViewHeightAboveScreen && tableView.isDragging {
            
            lastTweetId = tweetsViewModel.lastTweetId
            tweetsViewModel.feedRequest(lastTweetId) { [weak self] in
                guard let self = self else { return }
                self.lastTweetId = nil
                self.tableView.reloadData()
                
                self.letDataLoading = true
            }
            letDataLoading = false
        }
    }
}

extension FeedViewController: ComposeViewControllerProtocol {
    func tweetPublished(tweet: TweetModel) {
        let tweetViewModel = TweetViewModel(tweet: tweet)
        tweetsViewModel.addTweet(tweetViewModel)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}

extension FeedViewController: DetailsPopoverDelegate {
    func tweetDeleted(_ tweet: TweetViewModel) {
        detailsPopover?.removeFromSuperview()
        tweetsViewModel.removeTweet(tweet)
        tableView.deleteRows(at: [IndexPath(row: tweet.index, section: 0)], with: .automatic)
    }
    
    func deleteAlertConroller(_ tweet: TweetViewModel) {
        let alertController = UIAlertController(title: "Delete Tweet", message: "Are you sure you want to delete this Tweet?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.tweetService.deleteTweet(id: tweet.tweetId(), success: { [weak self] in
                self?.tweetDeleted(tweet)
                }, failure: { (error) in
                    print("deleting tweet error - ", error)
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        self.present(alertController, animated: true)
    }
}

extension FeedViewController {
    
    func composeViewController(inReply tweet: TweetViewModel?) {
        guard let navController = UIStoryboard.composeNavigationController(),
            let controller = navController.topViewController as? ComposeViewController else { return }
        
        controller.tweetVM = tweet
        controller.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
    func userProfileViewController(user: UserViewModel) {
        guard let profileViewController = UIStoryboard.profileViewController() else { return }
        profileViewController.user = user
        profileViewController.loggedUser = loggedUser
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
