//
//  SingleTweetViewController.swift
//  TwitterClone
//
//  Created by William Richman on 10/8/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import UIKit

class SingleTweetViewController: UIViewController {
    
    @IBOutlet weak var singleTweetBannerImage: UIImageView!
    @IBOutlet weak var singleTweetUserBar: UIView!
    @IBOutlet weak var singleTweetRTsCount: UILabel!
    @IBOutlet weak var singleTweetFavoritesCount: UILabel!
    @IBOutlet weak var singleTweetText: UILabel!
    @IBOutlet weak var singleTweetTwitterHandle: UILabel!
    @IBOutlet weak var singleTweetUserName: UILabel!
    @IBOutlet weak var singleTweetProfileImage: UIImageView!
    var tweetShown: Tweet?
    var imageCache = [String: UIImage]()
    
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
        self.singleTweetTwitterHandle.text = ("@\(self.tweetShown!.screenName)")
        self.singleTweetText.text = self.tweetShown!.text
        self.singleTweetFavoritesCount.text = String(self.tweetShown!.favoriteCount)
        self.singleTweetRTsCount.text = String(self.tweetShown!.retweetCount)
        self.singleTweetUserBar.layer.cornerRadius = self.singleTweetUserBar.frame.size.height * 0.1
        if let cachedProfileImage = self.imageCache[tweetShown!.screenName] {
            self.singleTweetProfileImage?.image = cachedProfileImage
        }
        else {
            NetworkController.controller.fetchProfileImage(tweetShown!, completionHandler: { (errorDescription, tweetProfileImage) -> Void in
                if errorDescription == nil {
                    self.imageCache[self.tweetShown!.screenName] = tweetProfileImage
                    self.singleTweetProfileImage?.image = self.imageCache[self.tweetShown!.screenName]
                }
                else {
                    println("Error: \(errorDescription)")
                }
            })
            
        }

        NetworkController.controller.fetchBackgroundProfileImage(self.tweetShown!, completionHandler: { (errorDescription, tweetProfileImage) -> Void in
            self.singleTweetBannerImage.contentMode = .ScaleAspectFill
            self.singleTweetBannerImage.clipsToBounds = true
            self.singleTweetBannerImage.image = tweetProfileImage
            self.singleTweetBannerImage.superview?.sendSubviewToBack(self.singleTweetBannerImage)
        })

        
        self.singleTweetProfileImage.layer.borderColor = UIColor.whiteColor().CGColor;
        self.singleTweetProfileImage.layer.borderWidth = self.singleTweetProfileImage.frame.size.width * 0.05
        self.singleTweetProfileImage.layer.cornerRadius = self.singleTweetProfileImage.frame.size.width * 0.1
        self.singleTweetProfileImage.clipsToBounds = true
        
        
        
        let press = UITapGestureRecognizer(target: self, action: Selector("segueAction:"))
        self.singleTweetProfileImage.addGestureRecognizer(press)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func segueAction(recognizer: UITapGestureRecognizer) {
        println("Action Fired")
        let userTimelineVC = self.storyboard?.instantiateViewControllerWithIdentifier("TIMELINE_VC") as HomeTimeLineViewController
        let userToDisplay = tweetShown?.screenName
        userTimelineVC.userTimelineShown = userToDisplay
        userTimelineVC.timelineType = "USER"
        userTimelineVC.tweetOrigin = tweetShown
        userTimelineVC.imageCache = self.imageCache
        self.navigationController?.pushViewController(userTimelineVC, animated: true)
    }
    
}
