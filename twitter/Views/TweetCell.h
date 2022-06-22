//
//  TweetCell.h
//  twitter
//
//  Created by Gui David on 6/20/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

NS_ASSUME_NONNULL_BEGIN

@interface TweetCell : UITableViewCell

// user info
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

@property (weak, nonatomic) IBOutlet Tweet *tweet;

@end

NS_ASSUME_NONNULL_END
