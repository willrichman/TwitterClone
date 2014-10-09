//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var userScreenNameLabel: UILabel!
    @IBOutlet weak var userProfileNameLabel: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    var timelineType = "HOME"
    var userTimelineShown : String?
    var tweetOrigin : Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "TimelineTweetTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TWEET_CELL")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        NetworkController.controller.fetchTimeLine(timelineType, userScreenname: userTimelineShown) { (errorDescription, tweets) -> Void in
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
        if timelineType == "HOME" {
            self.tableView.tableHeaderView = nil
        } else if timelineType == "USER" {
            self.userScreenNameLabel.text = tweetOrigin?.screenName
            self.userProfileNameLabel.text = tweetOrigin?.profileName
            self.userProfileImage.image = tweetOrigin?.profileImage
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
        if tweet?.profileImage != nil {
            cell.profileImage?.image = tweet?.profileImage
        }
        else {
            /* Download and set the profileImage */
            NetworkController.controller.fetchProfileImage(tweet!, completionHandler: { (errorDescription, tweetProfileImage) -> Void in
                let cellForImage = self.tableView.cellForRowAtIndexPath(indexPath) as TimelineTweetTableViewCell?
                if errorDescription == nil {
                    tweet?.profileImage = tweetProfileImage!
                    cellForImage?.profileImage?.image = tweet?.profileImage
                }
                else {
                    println(errorDescription)
                    cell.profileImage?.image = tweet?.defaultProfileImage
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
    
    
}
