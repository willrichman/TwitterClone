//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userProfileBackgroundImage: UIImageView!
    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    var timelineType = "HOME"
    var userTimelineShown : String?
    var tweetOrigin : Tweet?
    var refreshControl : UIRefreshControl?
    var imageCache = [String : UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "TimelineTweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        /* Taken from stackOverflow http://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift */
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refreshTweets:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        NetworkController.controller.fetchTimeLine(timelineType, isRefresh: false, newestTweet: nil, oldestTweet: nil, userScreenname: userTimelineShown) { (errorDescription, tweets) -> Void in
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
        
        /* Comment here */
        if timelineType == "HOME" {
            self.tableView.tableHeaderView = nil
        } else if timelineType == "USER" {
            self.userScreenNameLabel.text = tweetOrigin?.screenName
            self.userProfileNameLabel.text = tweetOrigin?.profileName
            NetworkController.controller.fetchBackgroundProfileImage(self.tweetOrigin!, completionHandler: { (errorDescription, tweetProfileImage) -> Void in
                self.userProfileBackgroundImage.contentMode = .ScaleAspectFill
                self.userProfileBackgroundImage.clipsToBounds = true
                self.userProfileBackgroundImage.image = tweetProfileImage
            })
            self.userProfileImage.image = self.imageCache[tweetOrigin!.screenName]
        }
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    func sortTweetsAtoZ() {
        self.tweets!.sort {$0.text < $1.text}
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
        cell.userScreenName?.text = ("@\(tweet!.screenName)")
        
        if let cachedProfileImage = self.imageCache[tweet!.screenName] {
            cell.profileImage?.image = cachedProfileImage
        }
        else {
            NetworkController.controller.fetchProfileImage(tweet!, completionHandler: { (errorDescription, tweetProfileImage) -> Void in
                if errorDescription == nil {
                    self.imageCache[tweet!.screenName] = tweetProfileImage
                    cell.profileImage?.image = self.imageCache[tweet!.screenName]
                }
                else {
                    println("Error: \(errorDescription)")
                }
            })

        }
        
        cell.profileImage?.layer.borderColor = UIColor.whiteColor().CGColor;
        cell.profileImage?.layer.borderWidth = cell.profileImage!.frame.size.width * 0.05
        cell.profileImage?.layer.cornerRadius = cell.profileImage!.frame.size.width * 0.1
        cell.profileImage?.clipsToBounds = true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let singleTweetVC = self.storyboard?.instantiateViewControllerWithIdentifier("SINGLE_TWEET_VC") as SingleTweetViewController
        var indexPath = tableView.indexPathForSelectedRow()
        tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        var tweetToDisplay = self.tweets![indexPath!.row] as Tweet
        singleTweetVC.tweetShown = tweetToDisplay
        self.navigationController?.pushViewController(singleTweetVC, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tweets!.count - 1 {
            NetworkController.controller.fetchTimeLine(timelineType, isRefresh: false, newestTweet: self.tweets?[0], oldestTweet: self.tweets?.last, userScreenname: userTimelineShown, completionHandler: { (errorDescription, tweets) -> Void in
                if errorDescription != nil {
                    //alert the user that something went wrong
                } else {
                    
                    var interimTweets = tweets!
                    let tweetRemoved = interimTweets.removeAtIndex(0)
                    self.tweets? += interimTweets
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func refreshTweets (sender: AnyObject) {
        NetworkController.controller.fetchTimeLine(timelineType, isRefresh: true, newestTweet: self.tweets?[0], oldestTweet: nil, userScreenname: userTimelineShown) { (errorDescription, tweets) -> Void in
            if errorDescription != nil {
                //alert the user that something went wrong
                self.refreshControl?.endRefreshing()
            } else {
                println(self.tweets?.count)
                var tweetsInterim : [Tweet]? = tweets
                tweetsInterim! += self.tweets!
                self.tweets = tweetsInterim!
                println(self.tweets?.count)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
}
