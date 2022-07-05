//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "APIManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "DateTools.h"


@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfTweets;
@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Fetch timeline data from API
    [self fetchTimeline];
    
    // Add Refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
}


/*!
    @brief Reloads the data whenever the table view is about to appear.
 
    @discussion This method is called every time the view is about to show up. It is mostly relevant when the detail views page is dismissed.
*/
- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}


/*!
    @brief This method is called by the refresh control whenever the user pulls-to-refresh
 
    @discussion This method refetches the timeline and signals the refreshControl to stop spinning.
 
    @param  refreshControl  The refresh control functionality.
*/
- (void)beginRefresh:(UIRefreshControl *)refreshControl {
      [self fetchTimeline];
      [refreshControl endRefreshing];
}


/*!
    @brief This method fetches the timeline using the APIManager
 
    @discussion This method reloads the tableView data automatically if the fetching was succesful, otherwise it throws an error.
*/
- (void)fetchTimeline {
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            for (Tweet *tweet in tweets) {
                NSString *text = tweet.text;
                NSLog(@"%@", text);
            }
            self.arrayOfTweets = (NSMutableArray *)tweets;
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

/*!
    @brief This method has the purpose of sending data to the details view controller.
 
    @discussion This method is called whenever a tweet cell is pressed
 
    @param  segue  The storyboard that will follow, Sender  The refresh control functionality.
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual:@"detailIdentifier"]) {
        Tweet *tweetToPass = self.arrayOfTweets[[self.tableView indexPathForCell:sender].row];
        DetailsViewController *detailVC = [segue destinationViewController];
        detailVC.tweet = tweetToPass;
    }
}

/*!
    @brief This method inserts a new tweet in the UI after the user composed a tweet.
 
    @discussion This method inserts a method at index zero so that the UI displays it on top.
 
    @param  tweet  The tweet recently composed by the author
*/
- (void)didTweet:(Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

/*!
    @brief This method logs the user out when they press the button.
 
    @param  sender  The logout button.
*/
- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;

    [[APIManager shared] logout];
}


/*!
    @brief This method returns the number of elements to be displayed in table view.
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

/*!
    @brief This method updates the table view with existing tweets.
 
    @discussion This method sets all relevant data in each cell.
 
    @param  indexPath  The index of the row (a given tweet on the table)
*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    
    Tweet *tweet = self.arrayOfTweets[indexPath.row];
    
    cell.tweet = tweet;
    
    // formats user handle string to include @
    NSString *formattedUserHandle = [NSString stringWithFormat:@"%s%@", "@", tweet.user.screenName];
    cell.userHandle.text = formattedUserHandle;
    
    cell.userName.text = tweet.user.name;
    cell.tweetContent.text = tweet.text;
    
    cell.likesNum.text = @(tweet.favoriteCount).stringValue;
    cell.retweetNum.text = @(tweet.retweetCount).stringValue;
    
    cell.tweetDate.text = tweet.createdAtString;
    
    // GD create a function that does encapsulates the two checks below
    if (tweet.favorited == YES) {
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon-red"];
        [cell.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"favor-icon"];
        [cell.favoriteButton setImage:pressedImg forState:UIControlStateNormal];
    }
    
    if (tweet.retweeted == YES) {
        // Update cell UI
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon-green"];
        [cell.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    } else {
        UIImage *pressedImg = [UIImage imageNamed:@"retweet-icon"];
        [cell.retweetButton setImage:pressedImg forState:UIControlStateNormal];
    }

    
    NSString *URLString = tweet.user.profilePicture;
    URLString = [URLString stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *url = [NSURL URLWithString:URLString];
    // NSData *urlData = [NSData dataWithContentsOfURL:url];
    cell.profilePicture.image = nil;
    [cell.profilePicture setImageWithURL:url];
    
    return cell;
}


@end
