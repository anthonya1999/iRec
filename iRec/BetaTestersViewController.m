//
//  BetaTestersViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "BetaTestersViewController.h"

@interface BetaTestersViewController ()

@end

@implementation BetaTestersViewController

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"betaTestersViewController"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=JackFrostMiner"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/JackFrostMiner"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=JackFrostMiner"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/JackFrostMiner"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
        }
        
        if (indexPath.row == 1) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=WorldOfGamingTV"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/WorldOfGamingTV"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=WorldOfGamingTV"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/WorldOfGamingTV"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
            
        }
        if (indexPath.row == 2) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=NoteworthyGames"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/NoteworthyGames"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=NoteworthyGames"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/NoteworthyGames"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
            
        }
        
        if (indexPath.row == 3) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=martyk96"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/martyk96"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=martyk96"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/martyk96"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
        }
        
        if (indexPath.row == 4) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=AceCraftPE"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/AceCraftPE"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=AceCraftPE"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/AceCraftPE"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
        }
        
        if (indexPath.row == 5) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=kennethmmcd"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/kennethmmcd"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=kennethmmcd"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/kennethmmcd"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
