//
//  NetworkController.swift
//  TwitterClone
//
//  Created by William Richman on 10/8/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
    
    class var controller: NetworkController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : NetworkController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NetworkController()
        }
        return Static.instance!
    }
    
    var twitterAccount : ACAccount?
    let profileImageQueue = NSOperationQueue()
    
    init () {
        self.profileImageQueue.maxConcurrentOperationCount = 6
    }
    
    func fetchTimeLine (timelineType: String, isRefresh: Bool, newestTweet: Tweet?, userScreenname: String?, completionHandler: (errorDescription : String?, tweets : [Tweet]?) -> Void) {
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        /*  The following is asynchronous.
        We will ask for account access, set up a twitter request, then call the home timeline   */
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                
                /* User gave access */
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as? ACAccount
                
                /* Set up our twitter request, depending on which timeline is requested*/
                var timelineURL : NSURL?
                var parameters: Dictionary<String, String>?
                
                switch timelineType {
                case "HOME":
                    timelineURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                case "USER":
                    timelineURL = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json")
                    parameters = ["screen_name": userScreenname!]
                default:
                    println("That timeline type doesn't work")
                }
                
                if isRefresh {
                    if parameters != nil {
                        parameters!["since_id"] = newestTweet!.id
                    }
                    else {
                        parameters = ["since_id": newestTweet!.id]
                    }
                }
                
                /* Make request */
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: timelineURL, parameters: parameters)
                twitterRequest.account = self.twitterAccount
                
                /* Make network call/request */
                twitterRequest.performRequestWithHandler({ (timeLineJSONData, httpResponse, error) -> Void in
                    if error == nil {
                        switch httpResponse.statusCode {
                            
                        case 200...299:
                            let tweets = Tweet.parseJSONDataIntoTweets(timeLineJSONData)
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                completionHandler(errorDescription: nil, tweets: tweets)
                            })
                        case 400...499:
                            println("error on the client")
                            println(httpResponse.description)
                            completionHandler(errorDescription: "The connection is having problems", tweets: nil)
                        case 500...599:
                            println("error on the server")
                        default:
                            println("something bad happened")
                            
                        }
                    }
                    else {
                        println(error)
                    }
                })
            }
                
            else {
                
            }
        }
        

    }
    
    func fetchProfileImage (tweet: Tweet, completionHandler: (errorDescription : String?, tweetProfileImage: UIImage?) -> Void) {
        self.profileImageQueue.addOperationWithBlock { () -> Void in
            let profileImageURL = NSURL(string: tweet.profileImageURL)
            let userProfileImageData = NSData(contentsOfURL: profileImageURL)
            let userProfileImage = UIImage(data: userProfileImageData, scale: UIScreen.mainScreen().scale)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(errorDescription: nil, tweetProfileImage: userProfileImage)
            })
        }
    }
    
    func fetchBackgroundProfileImage (tweet: Tweet, completionHandler: (errorDescription : String?, backgroundProfileImage: UIImage?) -> Void) {
        self.profileImageQueue.addOperationWithBlock { () -> Void in
            let backgroundImageURL = NSURL(string: tweet.profileBackgroundImageURL)
            println(tweet.profileBackgroundImageURL)
            let backgroundImageData = NSData(contentsOfURL: backgroundImageURL)
            let backgroundImage = UIImage(data: backgroundImageData)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(errorDescription: nil, backgroundProfileImage: backgroundImage)
            })
        }
    }
    
    func fetchTweetDetails (tweet: Tweet, completionHandler: (errorDescription : String?, tweet: Tweet) -> Void) {
        /* A redundant method.  Created originally to pull more detailed JSON on tweet, before we discovered that the keys we needed were already called in the HomeTimeLine call */
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        /*  The following is asynchronous.
        We will ask for account access, set up a twitter request, then call the home timeline   */
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                
                /* User gave access */
                let accounts = accountStore.accountsWithAccountType(accountType)
                self.twitterAccount = accounts.first as? ACAccount
                /* Set up our twitter request */
                let tweetDetailURL = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json")
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: tweetDetailURL, parameters: ["id": tweet.id])
                twitterRequest.account = self.twitterAccount
                /* Make network call/request */
                twitterRequest.performRequestWithHandler({ (HomeTimeLineJSONData, httpResponse, error) -> Void in
                    if error == nil {
                        switch httpResponse.statusCode {
                            
                        case 200...299:
                            let tweets = Tweet.parseJSONDataIntoTweets(HomeTimeLineJSONData)
                            println(tweets?.count)
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                
                            })
                        case 400...499:
                            println("error on the client")
                            println(httpResponse.description)
                            
                        case 500...599:
                            println("error on the server")
                        default:
                            println("something bad happened")
                            
                        }
                    }
                    else {
                        println(error)
                    }
                })
            }
                
            else {
                
            }
        }

    }
}