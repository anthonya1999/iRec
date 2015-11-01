//
//  CreditTableViewController.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@interface CreditTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end