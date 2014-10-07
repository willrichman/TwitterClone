//
//  Tweet.swift
//  TwitterClone
//
//  Created by William Richman on 10/6/14.
//  Copyright (c) 2014 Will Richman. All rights reserved.
//

import Foundation

class Tweet {
    
    var text : String
    var timeStamp : NSDate
    var profileName : String
    var profileImageURL : String
    var screenName : String
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
        self.profileImageURL = userProfile["profile_image_url"] as String
        let baseScreenName = userProfile["screen_name"] as String
        self.screenName = "@\(baseScreenName)"
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
