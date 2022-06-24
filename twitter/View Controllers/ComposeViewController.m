//
//  ComposeViewController.m
//  twitter
//
//  Created by Gui David on 6/21/22.
//  Copyright © 2022 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "TimelineViewController.h"
#import "APIManager.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UINavigationItem *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;
@property (weak, nonatomic) IBOutlet UITextView *composeTextArea;
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Settings for the compose text area
    [self.composeTextArea.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.composeTextArea.layer setBorderWidth:2.0];
    self.composeTextArea.layer.cornerRadius = 10;
    self.composeTextArea.clipsToBounds = YES;
}

/*!
    @brief This method handles the submission of a tweet
  
    @param  sender  The submit button
*/
- (IBAction)submitTweet:(id)sender {
    NSString *tweetContext = self.composeTextArea.text;
    
    [[APIManager shared] postStatusWithText:tweetContext completion:^(Tweet *tweet, NSError *error) {
        if (error) {
            return NSLog(@"Error composing tweet: %@", error.localizedDescription);
        } else {
            NSLog(@"😎😎😎 Successfully added tweet");
            [self.delegate didTweet:tweet];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

- (IBAction)closeTweetCompose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
