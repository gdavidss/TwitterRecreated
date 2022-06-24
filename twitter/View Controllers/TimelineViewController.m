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

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}


- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    /*
     This function is called by the refresh control whenever the user pulls-to-refresh
     */
          [self fetchTimeline];
          
         // Reload the tableView now that there is new data
          [self.tableView reloadData];

         // Tell the refreshControl to stop spinning
          [refreshControl endRefreshing];
}

- (void)fetchTimeline {
    /*
     Fetches data from the twitter API and stores it in self.arrayOfTweets
     */
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual:@"detailIdentifier"]) {
        Tweet *tweetToPass = self.arrayOfTweets[[self.tableView indexPathForCell:sender].row];
        DetailsViewController *detailVC = [segue destinationViewController];
        detailVC.tweet = tweetToPass;
    }
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//   UINavigationController *navigationController = [segue destinationViewController];
//   ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
//   composeController.delegate = self;
//}

- (void)didTweet:(Tweet *)tweet {
    [self.arrayOfTweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}


- (IBAction)didTapLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;

    [[APIManager shared] logout];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTweets.count;
}

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
