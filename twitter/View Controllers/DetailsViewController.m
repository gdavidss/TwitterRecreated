//
//  DetailsViewController.m
//  twitter
//
//  Created by Gui David on 6/22/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Tweet.h"
#import "APIManager.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userHandle;

// tweet info
@property (weak, nonatomic) IBOutlet UILabel *tweetDate;
@property (weak, nonatomic) IBOutlet UILabel *tweetContent;

// numbers
@property (weak, nonatomic) IBOutlet UILabel *retweetNum;
@property (weak, nonatomic) IBOutlet UILabel *likesNum;

// buttons
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@end

@implementation DetailsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTweetUser];
    [self loadTweetInfos];
    [self checkFavoriteAndRetweet];
}


/*!
    @brief This function sets the label texts and profile picture of the user who made the shown tweet.
 
    @discussion This method is called when the details view page appears.
*/
- (void)loadTweetUser{
    // Loads info about the user
    self.userName.text = self.tweet.user.name;

    NSString *URLString = self.tweet.user.profilePicture;
    URLString = [URLString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *url = [NSURL URLWithString:URLString];
    // NSData *urlData = [NSData dataWithContentsOfURL:url];
    self.profilePicture.image = nil;
    [self.profilePicture setImageWithURL:url];
}


/*!
    @brief This function sets the label texts of the tweet cell accordingly.
 
    @discussion This method is called when the details view page appears.
*/
- (void)loadTweetInfos {
    // Loads info about tweet content and stats
    self.tweetContent.text = self.tweet.text;

    // formats user handle string to include @
    NSString *formattedUserHandle = [NSString stringWithFormat:@"%s%@", "@", self.tweet.user.screenName];
    self.userHandle.text = formattedUserHandle;
    
    self.likesNum.text = @(self.tweet.favoriteCount).stringValue;
    self.retweetNum.text = @(self.tweet.retweetCount).stringValue;
    self.tweetDate.text = self.tweet.createdAtString;
    
    UIImage *replyImg = [UIImage imageNamed:@"reply-icon"];
    [self.favoriteButton setImage:replyImg forState:UIControlStateNormal];
    
    UIImage *messageImg = [UIImage imageNamed:@"message-icon"];
    [self.messageButton setImage:messageImg forState:UIControlStateNormal];
}


/*!
    @brief This function checks if the tweet and favorite button was pressed.
 
    @discussion This method is called when the details view page appears.
*/
-(void)checkFavoriteAndRetweet{
    if (self.tweet.favorited == YES) {
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon-red"];
        [self.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
        // GD use set image programatically before
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon"];
        [self.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
    }
    if (self.tweet.retweeted == YES) {
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon-green"];
        [self.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon"];
        [self.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
