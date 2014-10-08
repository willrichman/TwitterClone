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
    
    /*class var sharedInstance: NetworkController {
    struct Static {
        static var instance: NetworkController?
        static var token: dispatch_once_t = 0
        }
        dispatch_one(&Static.token) {
            Static.instace = NetworkController()
        }
    }*/
    
    var twitterAccount : ACAccount?
    
    init () {
        
    }
    
    func fetchHomeTimeLine (completionHandler: (errorDescription : String?, tweets : [Tweet]?) -> Void) {
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
                let homeTimelineURL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                let twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: homeTimelineURL, parameters: nil)
                twitterRequest.account = self.twitterAccount
                /* Make network call/request */
                twitterRequest.performRequestWithHandler({ (HomeTimeLineJSONData, httpResponse, error) -> Void in
                    
                    switch httpResponse.statusCode {
                        
                    case 200...299:
                        let tweets = Tweet.parseJSONDataIntoTweets(HomeTimeLineJSONData)
                        println(tweets?.count)
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
                })
            }
                
            else {
                
            }
        }
        

    }

}