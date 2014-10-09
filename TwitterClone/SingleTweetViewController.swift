//
//  SingleTweetViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/8/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
    
    @IBOutlet weak var singleTweetRTsCount: UILabel!
    @IBOutlet weak var singleTweetFavoritesCount: UILabel!
    @IBOutlet weak var singleTweetText: UILabel!
    @IBOutlet weak var singleTweetTwitterHandle: UILabel!
    @IBOutlet weak var singleTweetUserName: UILabel!
    @IBOutlet weak var singleTweetProfileImage: UIImageView!
    var tweetShown: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.singleTweetUserName.text = self.tweetShown!.profileName
        self.singleTweetTwitterHandle.text = self.tweetShown!.screenName
        self.singleTweetText.text = self.tweetShown!.text
        self.singleTweetProfileImage.image = self.tweetShown!.profileImage
        self.singleTweetFavoritesCount.text = String(self.tweetShown!.favoriteCount)
        self.singleTweetRTsCount.text = String(self.tweetShown!.retweetCount)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
