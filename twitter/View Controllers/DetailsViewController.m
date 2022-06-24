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

- (void)loadTweetInfos {
    // Loads info about tweet content and stats
    self.tweetContent.text = self.tweet.text;

    // formats user handle string to include @
    NSString *formattedUserHandle = [NSString stringWithFormat:@"%s%@", "@", self.tweet.user.screenName];
    self.userHandle.text = formattedUserHandle;
    
    self.likesNum.text = @(self.tweet.favoriteCount).stringValue;
    self.retweetNum.text = @(self.tweet.retweetCount).stringValue;
    self.tweetDate.text = self.tweet.createdAtString;
}

-(void)checkFavoriteAndRetweet{
    // checks if tweet was favorited
    if (self.tweet.favorited == YES) {
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon-red"];
        [self.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
        // GD use set image programatically before
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon"];
        [self.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
    }
    
    // check if tweet was retweeted
    if (self.tweet.retweeted == YES) {
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon-green"];
        [self.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon"];
        [self.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    }
}

- (void)refreshCellData {
    self.likesNum.text = @(self.tweet.favoriteCount).stringValue;
    self.retweetNum.text = @(self.tweet.retweetCount).stringValue;
    self.tweetDate.text = self.tweet.createdAtString;
}

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
