//
//  CreditTableViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import "CreditTableViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "UpdateViewController.h"
#import "LegalViewController.h"
#import "BetaTestersViewController.h"
#import "UIImage+ImageEffects.h"

@interface CreditTableViewController ()

@end

@implementation CreditTableViewController

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
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=Emu4iOS"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/Emu4iOS"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=Emu4iOS"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/Emu4iOS"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
        }
        
        
        if (indexPath.row == 1) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=AAgatiello"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/AAgatiello"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=AAgatiello"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/AAgatiello"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
        }
        
        if (indexPath.row == 2) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=iNoCydia_Devs"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/iNoCydia_Devs"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=iNoCydia_Devs"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/iNoCydia_Devs"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
            
            
        }
        if (indexPath.row == 3) {
            NSString *scheme = @"";
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) // Twitter
            {
                scheme = [NSString stringWithFormat:@"twitter://user?screen_name=HamzaSood"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) // Tweetbot
            {
                scheme = [NSString stringWithFormat:@"tweetbot:///user_profile/HamzaSood"];
            }
            else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) // Twitterrific
            {
                scheme = [NSString stringWithFormat:@"twitterrific:///profile?screen_name=HamzaSood"];
            }
            else
            {
                scheme = [NSString stringWithFormat:@"http://twitter.com/HamzaSood"];
            }
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scheme]];
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
        if (indexPath.row == 0) {
            
            UIGraphicsBeginImageContext(self.view.bounds.size);
            CGContextRef c = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(c, 0, 0);
            [self.view.layer renderInContext:c];
            UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
            viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
            UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
            [self.view addSubview:blurredView];
            UIGraphicsEndImageContext();
            
            UIAlertView *bugAlert = [[UIAlertView alloc] initWithTitle:@"Report Bug" message:@"Thank you for using iRec and giving us feedback so we can make it even better! Please tell us the bug you are experiencing via Twitter or E-Mail as specifically as possible! Are you sure you want to report a bug?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Twitter", @"E-Mail", nil];
            
            [bugAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [blurredView removeFromSuperview];
                }
                if (buttonIndex == 1) {
                    //Twitter
                    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                    [tweetSheet setInitialText:@"@AAgatiello @Emu4iOS iRec Bug: *remove this text, and enter description here*"];
                    [self presentViewController:tweetSheet animated:YES completion:nil];
                    [blurredView removeFromSuperview];
                }
                if (buttonIndex == 2) {
                    //E-Mail
                    NSString *subject = @"iRec Bug";
                    NSArray *recipients = [NSArray arrayWithObject:@"emu4ioshelp@gmail.com"];
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:subject];
                    [mc setMessageBody:nil isHTML:NO];
                    [mc setToRecipients:recipients];
                    [self presentViewController:mc animated:YES completion:nil];
                    [blurredView removeFromSuperview];
                }
                else {
                    //do nothing
                }
            }];
        }
    }
    
    if (indexPath.section == 4) {
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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"dark_theme_switch"]) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    else {
        //set nothing differently...
    }
    
    NSString *bundleVersionForLabel = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString *versionForLabel = [NSString stringWithFormat:@"v%@",bundleVersionForLabel];
    _versionLabel.text = versionForLabel;
}

@end
