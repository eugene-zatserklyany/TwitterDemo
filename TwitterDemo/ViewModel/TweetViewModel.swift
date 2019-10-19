//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 3/26/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import Foundation
import TwitterBusinessLayer

class TweetViewModel {
    private var tweetService = TweetService()

    lazy var index = 0

    var tweet: TweetModel

    init(tweet: TweetModel) {
        self.tweet = tweet
    }

    func name() -> String {
        return tweet.user.name
    }

    func date() -> String {
        return String.formatTweetDate(dateString: tweet.date)
    }

    func username() -> String {
        return "@" + tweet.user.screenName
    }

    func profileImageUrl() -> URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    func message() -> String {
        return tweet.text
    }

    func tweetId() -> String {
        return tweet.tweetId
    }

    func favoriteCount() -> Int {
        return tweet.favoriteCount
    }

    func isLiked() -> Bool {
        return tweet.favorited
    }

    func retweetCount() -> Int {
        return tweet.retweetCount
    }

    func isRetweeted() -> Bool {
        return tweet.retweeted
    }

    func user() -> UserViewModel {
        return UserViewModel(user: tweet.user)
    }

    func mediaURLs() -> [URL]? {
        guard let mediaModel = tweet.mediaEntities?.media else { return nil }
        let mediaUrls = mediaModel.compactMap { URL(string: $0.mediaUrl) }.prefix(4)
        return Array (mediaUrls)
    }

    func link() -> URL? {
        return tweetService.tweetURL(username: tweet.user.screenName, id: tweet.tweetId)
    }
    
    func urls(isShorten: Bool = true) -> [String]? {
        guard let urlsModel = tweet.tweetEntities?.urls else { return nil }
        let shortUrls = urlsModel.compactMap { $0.shortUrl }
        let expandedUrls = urlsModel.compactMap { $0.expandedURl }
        
        guard !shortUrls.isEmpty, !expandedUrls.isEmpty else { return nil }
        return isShorten ? shortUrls : expandedUrls
    }

    func composeMessage(replyWith message: String) -> String {
        return username() + " " + message
    }


    private func updateLikeStatus() {
        let isLikedCurrently = !tweet.favorited
        tweet.favoriteCount += isLikedCurrently == true ? 1 : -1
        tweet.favorited = isLikedCurrently
    }

    private func updateRetweetStatus() {
        let isRetweetedCurrently = !tweet.retweeted
        tweet.retweetCount += isRetweetedCurrently == true ? 1 : -1
        tweet.retweeted = isRetweetedCurrently
    }
}

extension TweetViewModel {


    public func like(completion: @escaping () -> ()) {
        tweetService.like(tweetId: tweetId(), destroy: isLiked(), success: { [weak self] (data) in
            self?.updateLikeStatus()
            completion()
            }, failure: { (error) in
                print("like error ", error)
        })
    }

    public func retweet(completion: @escaping () -> ()) {
        tweetService.retweet(tweetId: tweetId(), unretweet: isRetweeted(), success: { [weak self] (data) in
            self?.updateRetweetStatus()
            completion()
            }, failure: { (error) in
                print("like error ", error)
        })
    }
}

