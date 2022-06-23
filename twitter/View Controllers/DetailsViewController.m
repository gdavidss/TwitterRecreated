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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
