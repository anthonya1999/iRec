//
//  CreditTableViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <Social/Social.h>
#import "ScreenRecorder.h"
#import "CreditTableViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "UpdateViewController.h"
#import "LegalViewController.h"
#import "BetaTestersViewController.h"
#import "WatchSupportViewController.h"
#import <FXBlurView/FXBlurView.h>

@interface CreditTableViewController ()

@end

@implementation CreditTableViewController

- (NSUserDefaults *)defaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return prefs;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self openTwitterAccountWithUsername:@"Emu4iOS"];
        }
        
        if (indexPath.row == 1) {
            [self openTwitterAccountWithUsername:@"iNoCydia_Devs"];
        }
        
        if (indexPath.row == 2) {
            [self openTwitterAccountWithUsername:@"AAgatiello"];
        }
        
        if (indexPath.row == 3) {
            [self openTwitterAccountWithUsername:@"HamzaSood"];
        }
        
        if (indexPath.row == 4) {
            BetaTestersViewController *betaTestersViewController = [[BetaTestersViewController alloc] init];
            [self.navigationController pushViewController:betaTestersViewController animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UpdateViewController *updateViewController = [[UpdateViewController alloc] init];
            [self.navigationController pushViewController:updateViewController animated:YES];
        }
    }
    
    if (indexPath.section == 3) {
        WatchSupportViewController *watchSupportViewController = [[WatchSupportViewController alloc] init];
        [self.navigationController pushViewController:watchSupportViewController animated:YES];
    }

    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            
            ScreenRecorder *screenRecorder = [[ScreenRecorder alloc] init];
            FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, [screenRecorder screenWidth] * 4, [screenRecorder screenHeight] * 4)];
            [blurView setDynamic:YES];
            blurView.tintColor = [UIColor clearColor];
            blurView.blurRadius = 8;
            [self.view addSubview:blurView];
            
            UIAlertView *bugAlert = [[UIAlertView alloc] initWithTitle:@"Report Bug" message:@"Thank you for using iRec and giving us feedback so we can make it even better! Please tell us the bug you are experiencing via Twitter or E-Mail as specifically as possible! Are you sure you want to report a bug?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Twitter", @"E-Mail", nil];
            
            [bugAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [blurView removeFromSuperview];
                }
                if (buttonIndex == 1) {
                    //Twitter
                    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    [tweetSheet setInitialText:@"@AAgatiello @Emu4iOS iRec Bug: *remove this text, and enter description here*"];
                    [self presentViewController:tweetSheet animated:YES completion:nil];
                    [blurView removeFromSuperview];
                }
                if (buttonIndex == 2) {
                    //E-Mail
                    NSString *subject = @"iRec Bug";
                    NSArray *recipients = [NSArray arrayWithObject:@"irecbug@gmail.com"];
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:subject];
                    [mc setMessageBody:@"" isHTML:NO];
                    [mc setToRecipients:recipients];
                    [self presentViewController:mc animated:YES completion:nil];
                    [blurView removeFromSuperview];
                }
                else {
                    //do nothing
                }
            }];
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            LegalViewController *legalViewController = [[LegalViewController alloc] init];
            [self.navigationController pushViewController:legalViewController animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"E-Mail cancelled.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"E-Mail saved.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"E-Mail sent.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"E-Mail send failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    else {
        //set nothing differently...
    }
    
    NSString *bundleVersionForLabel = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString *versionForLabel = [NSString stringWithFormat:@"v%@",bundleVersionForLabel];
    _versionLabel.text = versionForLabel;
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
