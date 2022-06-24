//
//  TweetCell.m
//  twitter
//
//  Created by Gui David on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"
#import "DateTools.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
   // self.tweetDate.text = [self.tweet.createdAtString shortTimeAgoSinceNow];
}


/*!
    @brief Refreshes the number of likes and retweets, as well as the tweet date in the cell.
 
    @discussion This method is called every time the user taps the retweet and favorite button.
*/
- (void)refreshCellData {
    self.likesNum.text = @(self.tweet.favoriteCount).stringValue;
    self.retweetNum.text = @(self.tweet.retweetCount).stringValue;
    self.tweetDate.text = self.tweet.createdAtString;
}


/*!
    @brief Handles tapping the favorite button.
 
    @discussion This method is called every time the favorite button is pressed. It sends a API request to favorite/unfavorite the tweet.
 
    @param  sender  The favorite button.
 */
- (IBAction)didTapFavorite:(id)sender {
    if (self.tweet.favorited == YES) {
        // Update the local tweet model
        self.tweet.favorited = NO;
        self.tweet.favoriteCount -= 1;
        
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon"];
        [sender setImage:pressedImg forState:UIControlStateNormal];
        [self refreshCellData];
        
        //   Send a POST request to the POST favorites/create endpoint
         [[APIManager shared] unfavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
             }
             else {
                 NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
             }
         }];
    } else {
        // Update the local tweet model
        self.tweet.favorited = YES;
        self.tweet.favoriteCount += 1;
        
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon-red"];
        [sender setImage:pressedImg forState:UIControlStateNormal];
        [self refreshCellData];
        
        // Send a POST request to the POST favorites/create endpoint
         [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
             if(error){
                  NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
             }
             else {
                 NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
             }
         }];
    }
}


/*!
    @brief Handles tapping the retweet button.
 
    @discussion This method is called every time the retweet button is pressed. It sends a API request to favorite/unfavorite the tweet.
 
    @param  sender  The retweet button.
 */
- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted == YES) {
        // Update the local tweet model
        self.tweet.retweeted = NO;
        self.tweet.retweetCount -= 1;
        
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon"];
        [sender setImage:pressedImg forState:UIControlStateNormal];
        [self refreshCellData];
        
        // Send a POST request to the POST retweet endpoint
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Successfully unretweeted the following Tweet: %@", tweet.text);
            }
        }];
    } else {
        // Update the local tweet model
        self.tweet.retweeted = YES;
        self.tweet.retweetCount += 1;
        
        // Update cell UI
        // GD maybe create a function that sets image automatically
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon-green"];
        [sender setImage:pressedImg forState:UIControlStateNormal];
        [self refreshCellData];
        
        // Send a POST request to the POST retweet endpoint
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error) {
                 NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
