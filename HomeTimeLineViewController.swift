//
//  HomeTimeLineViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class HomeTimeLineViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tweets : [Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        if let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") {
            var error : NSError?
            let jsonData = NSData(contentsOfFile: path)
            
            self.tweets = Tweet.parseJSONDataIntoTweets(jsonData)
            
            println(tweets?.count)
            self.sortTweetsAtoZ()
            println(self.tweets![0].timeStamp)
            println(self.tweets![1].timeStamp)
            println(self.tweets![2].timeStamp)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.sortTweetsAtoZ()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TWEET_CELL", forIndexPath: indexPath) as UITableViewCell
        
        /* This is where we will grab reference to correct tweet and use it to configure the cell*/
        
        let tweet = self.tweets?[indexPath.row]
        cell.textLabel?.text = tweet?.text
        cell.backgroundColor = UIColor.lightGrayColor()
        return cell
    }
    
}
