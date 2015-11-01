//
//  BetaTestersViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "BetaTestersViewController.h"

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
        
        NSString *username = nil;
        
        if (indexPath.row == 0) {
           username = @"JackFrostMiner";
        }
        
        if (indexPath.row == 1) {
           username = @"WorldOfGamingTV";
        }
        
        if (indexPath.row == 2) {
           username = @"NoteworthyGames";
        }
        
        if (indexPath.row == 3) {
            username = @"martyk96";
        }
        
        if (indexPath.row == 4) {
            username = @"AceCraftPE";
        }
        
        if (indexPath.row == 5) {
           username = @"kennethmmcd";
        }
        
        [self openTwitterAccountWithUsername:username];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)openTwitterAccountWithUsername:(NSString *)username {
    NSString *scheme = @"";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
    {
        scheme = [NSString stringWithFormat:@"twitter://user?screen_name=%@",username];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
    {
        scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/%@",username];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
    {
        scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=%@",username];
    }
    else
    {
        scheme = [NSString stringWithFormat:@"http://twitter.com/%@",username];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
}

@end
