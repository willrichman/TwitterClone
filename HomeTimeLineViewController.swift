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
    var networkController : NetworkController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.networkController = appDelegate.networkController
        self.networkController.fetchHomeTimeLine { (errorDescription, tweets) -> Void in
            if errorDescription != nil {
                //alert the user that something went wrong
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        }
        
        /* Taken from AppCoda http://www.appcoda.com/self-sizing-cells/ */
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
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
        cell.userScreenName?.text = tweet?.screenName
        cell.profileImage?.image = tweet?.profileImage
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "singleTweetSegue" {
            var destination = segue.destinationViewController as SingleTweetViewController
            var indexPath = tableView.indexPathForSelectedRow()
            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
            var tweetToDisplay = self.tweets![indexPath!.row] as Tweet
            destination.tweetShown = tweetToDisplay
        }
    }
    
}
