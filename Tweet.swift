//
//  Tweet.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import Foundation
import UIKit

class Tweet {
    
    var text : String
    var timeStamp : NSDate
    var profileName : String
    var profileImageURL : String
    var profileBackgroundImageURL : String
    let defaultBanner = "https://pbs.twimg.com/profile_banners/783214/1347405327/600x200"
    var profileImage : UIImage?
    var screenName : String
    var id : String
    var favoriteCount : Int
    var retweetCount : Int
    let timeStampFormatter = NSDateFormatter()
    var formattedDate = NSDate()
    
    init (tweetDictionary : NSDictionary) {
        self.text = tweetDictionary["text"] as String
        
        /* Format the Twitter API timestamp into an NSDate object and assign it to timeStamp*/
        
        timeStampFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let formattedDate = timeStampFormatter.dateFromString(tweetDictionary["created_at"] as String) {
            self.formattedDate = formattedDate
        }
        else {
            self.formattedDate = NSDate()
        }
        self.timeStamp = self.formattedDate
        
        let userProfile = tweetDictionary["user"] as NSDictionary
        self.profileName = userProfile["name"] as String
        let smallProfileImageURL = userProfile["profile_image_url"] as String
        /*  Takes the URL string and changes it to pull Twitter's bigger profile image.
            Courtesy of Cameron Klein (github.com/cameronklein)                          */
        let normalRange = smallProfileImageURL.rangeOfString("_normal", options: nil, range: nil, locale: nil)
        self.profileImageURL = smallProfileImageURL.stringByReplacingCharactersInRange(normalRange!, withString: "_bigger")
        if let bannerURL = userProfile["profile_banner_url"] as? String {
            self.profileBackgroundImageURL = bannerURL
        }
        else {
            self.profileBackgroundImageURL = self.defaultBanner
        }
        
        self.screenName = userProfile["screen_name"] as String
        self.id = tweetDictionary["id_str"] as String
        self.favoriteCount = tweetDictionary["favorite_count"] as Int
        self.retweetCount = tweetDictionary["retweet_count"] as Int
    }
    
    class func parseJSONDataIntoTweets(rawJSONData : NSData) -> [Tweet]? {
        
        /* Generic error for JSONObject error protocol */
        var error : NSError?
        
        if let JSONArray = NSJSONSerialization.JSONObjectWithData(rawJSONData, options: nil, error: &error) as? NSArray{
            
            /* Empty array for tweets */
            var tweets = [Tweet]()
            
            for JSONDictionary in JSONArray {
                
                /*  Use optional binding to cast dictionary found in JSON as an NSDictionary
                    If successful, add this tweet as a dictionary to our tweet array           */
                
                if let tweetDictionary = JSONDictionary as? NSDictionary{
                    var newTweet = Tweet(tweetDictionary: tweetDictionary)
                    tweets.append(newTweet)
                }
            }
            return tweets
        }
        return nil
    }

}
