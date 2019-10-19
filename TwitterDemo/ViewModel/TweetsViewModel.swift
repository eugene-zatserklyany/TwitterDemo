//
//  TestViewModel.swift
//  TwitterDemo
//
//  Created by Eugene Zatserklyaniy on 5/3/19.
//  Copyright © 2019 Eugene Zatserklyaniy. All rights reserved.
//

import Foundation
import TwitterBusinessLayer

class TweetsViewModel {
    fileprivate var feedService: FeedService

    private var tweets = [TweetViewModel]()
    lazy var index = 0

    var tweet: TweetViewModel {
        get {
            return tweets[index]
        }
    }

    var count: Int {
        get {
            return self.tweets.count
        }
    }
    
    var userID: String?

    var lastTweetId: String? {
        return self.tweets.last?.tweetId()
    }

    init(feedService: FeedService, userID: String? = nil) {
        self.feedService = feedService
        self.userID = userID
    }
    
    func addTweet(_ tweet: TweetViewModel) {
        tweets.insert(tweet, at: 0)
    }
    
    func removeTweet(_ tweet: TweetViewModel) {
        tweets.remove(at: tweet.index)
    }
}

extension TweetsViewModel {
    public func feedRequest(_ lastTweetId: String? = nil, success: @escaping () -> ()) {
        feedService.fetchHomeTimeline(maxId: lastTweetId) { [weak self](result) in

            guard let self = self else { return }

            switch result {
            case .success(let value):

                if lastTweetId == nil {
                    self.tweets = self.mapTweets(tweets: value)
                } else {
                    self.tweets.removeLast()
                    self.tweets.append(contentsOf: self.mapTweets(tweets: value))
                }
                success()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func userFeedRequest(success: @escaping () -> ()) {
        guard let userID = userID else { return }
        feedService.fetchUserTimeline(userID: userID) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .success(let value):
                self.tweets = self.mapTweets(tweets: value)
                success()
            case .failure(let error):
                print(error)
            }
        }
    }

    private func mapTweets(tweets: [TweetModel]) -> [TweetViewModel] {
        return tweets.map({ (tweetVM) -> TweetViewModel in
            return TweetViewModel(tweet: tweetVM)
        })
    }
}
