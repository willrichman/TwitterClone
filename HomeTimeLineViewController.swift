//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit
import Accounts
import Social

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    var twitterAccount : ACAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
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
                        self.tweets = Tweet.parseJSONDataIntoTweets(HomeTimeLineJSONData)
                        println(self.tweets?.count)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.tableView.reloadData()
                        })
                    case 400...499:
                        println("error on the client")
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

        
//        if let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") {
//            var error : NSError?
//            let jsonData = NSData(contentsOfFile: path)
//            
//            self.tweets = Tweet.parseJSONDataIntoTweets(jsonData)
//            
//            println(tweets?.count)
//            self.sortTweetsAtoZ()
//            println(self.tweets![0].timeStamp)
//            println(self.tweets![1].timeStamp)
//            println(self.tweets![2].timeStamp)
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //self.sortTweetsAtoZ()
    }
    
    func sortTweetsAtoZ() {
        self.tweets!.sort {$0.text < $1.text}
    }
    
    func sortTweetsDate() {
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tweets != nil {
            return self.tweets!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as TimelineTweetTableViewCell
        
        /* This is where we will grab reference to correct tweet and use it to configure the cell*/
        
        let tweet = self.tweets?[indexPath.row]
        cell.tweetTextLabel?.text = tweet?.text
        cell.userNameTextLabel?.text = tweet?.profileName
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120.0
    }
    
}
